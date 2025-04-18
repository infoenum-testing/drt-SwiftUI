//
//  DRTDatabaseManager.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/02/25.
//

import CoreData
import UIKit
import IQAPIClient
import SwiftUI

class DRTDatabaseManager {
    var managedObjectContext: NSManagedObjectContext?
    @AppStorage("showCode") private var savedShowCode: String?
    static let shared: DRTDatabaseManager = {
        let context = PersistenceController.shared.container.viewContext
        return DRTDatabaseManager(context: context)
    }()
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }

    func syncServerData(serverDict: [String: Any], progressBlock: ((Float) -> Void)?, completionBlock: ((Bool, Error?) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            guard let context = self.managedObjectContext else {
                DispatchQueue.main.async { completionBlock?(false, NSError(domain: "CoreData", code: -1, userInfo: [NSLocalizedDescriptionKey: "Managed Object Context is nil"])) }
                return
            }

            self.deleteAllRecords()

            guard let show = self.insertUpdateShowRecord(showAttributes: serverDict, context: context) else {
                DispatchQueue.main.async { completionBlock?(false, NSError(domain: "CoreData", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to insert show"])) }
                return
            }

            let orders = serverDict["orders"] as? [[String: Any]] ?? []
            let seats = serverDict["seats"] as? [[String: Any]] ?? []
            let products = serverDict["products"] as? [[String: Any]] ?? []

            let totalRecords = Float(orders.count + seats.count + products.count)
            var processedRecords: Float = 0
            
            var orderDict: [NSNumber: Order] = [:]
            
            for orderData in orders {
                if let order = self.insertUpdateOrderRecord(orderAttributes: orderData, context: context) {
                    order.show = show
                    if let orderId = order.oid {
                        orderDict[orderId] = order
                    }
                }
                processedRecords += 1
                DispatchQueue.main.async { progressBlock?(processedRecords / totalRecords) }
            }

            for seatDict in seats {
                if let seat = self.insertSeatRecord(seatAttributes: seatDict, context: context) {
                    seat.show = show
                    
                    if let orderId = seatDict["order"] as? NSNumber, let linkedOrder = orderDict[orderId] {
                        seat.order = linkedOrder  
                    }
                }
                processedRecords += 1
                DispatchQueue.main.async { progressBlock?(processedRecords / totalRecords) }
            }

            for productDict in products {
                _ = self.insertProductRecord(productAttributes: productDict, context: context)
                processedRecords += 1
                DispatchQueue.main.async { progressBlock?(processedRecords / totalRecords) }
            }

            do {
                try context.save()
                DispatchQueue.main.async { completionBlock?(true, nil) }
            } catch {
                DispatchQueue.main.async { completionBlock?(false, error) }
            }
        }
    }

    // MARK: - Helper Functions

    private func deleteAllRecords() {
        deleteAllTableRecords(forEntity: Scan.self)
        deleteAllTableRecords(forEntity: Product.self)
        deleteAllTableRecords(forEntity: Seat.self)
        deleteAllTableRecords(forEntity: Order.self)
        deleteAllTableRecords(forEntity: Show.self)
    }
    
    func deleteSkin() {
        deleteAllTableRecords(forEntity: Skin.self)
    }

    private func deleteAllTableRecords<T: NSManagedObject>(forEntity entity: T.Type) {
        guard let context = managedObjectContext else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: entity))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Failed to delete \(entity): \(error.localizedDescription)")
        }
    }

    private func insertUpdateShowRecord(showAttributes: [String: Any], context: NSManagedObjectContext) -> Show? {
        let fetchRequest: NSFetchRequest<Show> = Show.fetchRequest()
        if let showId = showAttributes["show_id"] as? Int {
            fetchRequest.predicate = NSPredicate(format: "show_id == %d", showId)
        }
        
        let show = (try? context.fetch(fetchRequest).first) ?? Show(context: context)
        show.show_id = (showAttributes["show_id"] as? Int)?.description
        show.studio_id = (showAttributes["studio_id"] as? Int)?.description
        show.show_dt = showAttributes["show_dt"] as? String
        show.valid = NSNumber(value: showAttributes["valid"] as? Bool ?? false)
        show.db_code = showAttributes["db_code"] as? String
        return show
    }
    
    private func insertUpdateOrderRecord(orderAttributes: [String: Any], context: NSManagedObjectContext) -> Order? {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        if let orderId = orderAttributes["id"] as? Int {
            fetchRequest.predicate = NSPredicate(format: "oid == %d", orderId)
        }
        
        let order = (try? context.fetch(fetchRequest).first) ?? Order(context: context)
        order.oid = orderAttributes["id"] as? NSNumber
        order.buyer_name = orderAttributes["name"] as? String
        order.cc = orderAttributes["cc"] as? String
        order.phone = orderAttributes["phone"] as? String
        return order
    }
    
    private func insertSeatRecord(seatAttributes: [String: Any], context: NSManagedObjectContext) -> Seat? {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        if let barcode = seatAttributes["barcode"] as? String {
            fetchRequest.predicate = NSPredicate(format: "barcode == %@", barcode)
        }
        
        let seat: Seat
        if let existingSeat = try? context.fetch(fetchRequest).first {
            seat = existingSeat
        } else {
            seat = Seat(context: context)
        }
        
        seat.oid = seatAttributes["id"] as? NSNumber
        seat.order_id = seatAttributes["order"] as? NSNumber
        seat.barcode = seatAttributes["barcode"] as? String
        seat.qrCode = seatAttributes["qrCode"] as? String
        seat.handicapped = NSNumber(value: (seatAttributes["handicap"] as? Int ?? 0) == 1)
        
        if let scannedString = seatAttributes["scanned"] as? String {
               let formatter = DateFormatter()
               formatter.dateFormat = "h:mm a"
               formatter.locale = Locale(identifier: "en_US_POSIX")
               if let scannedDate = formatter.date(from: scannedString) {
                   seat.date_scanned = scannedDate
               }
           }
        
        if let secRowSeat = seatAttributes["secRowSeat"] as? String {
            let components = secRowSeat.split(separator: "-")
            if components.count == 3 {
                seat.section = String(components[0])
                seat.row = String(components[1])
                seat.seat = String(components[2])
            }
        }
        
        if let orderId = seatAttributes["order"] as? Int {
            let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "oid == %d", orderId)
            seat.order = try? context.fetch(fetchRequest).first
        }
        
        return seat
    }
    
    private func insertProductRecord(productAttributes: [String: Any], context: NSManagedObjectContext) -> Product? {
        let product = Product(context: context)

        product.name = productAttributes["name"] as? String
        product.variantName = productAttributes["variantName"] as? String
        product.qrCode = productAttributes["qrCode"] as? String
        product.qty = productAttributes["qty"] as? Int64 ?? 0
        product.qty_scanned = productAttributes["qty_scanned"] as? Int64 ?? 0
        product.icon_src = productAttributes["icon_src"] as? String
        product.order_id = (productAttributes["orderId"] as? Int64) ?? 0

        do {
            if context.hasChanges {
                try context.save()
                print("✅ Product saved with order_id \(product.order_id).")
            }
        } catch {
            print("❌ Error saving product: \(error.localizedDescription)")
            return nil
        }

        return product
    }
    
    func insertOrUpdateSkin(skinModel: SkinModel, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Skin> = Skin.fetchRequest()

        let skin = (try? context.fetch(fetchRequest).first) ?? Skin(context: context)
        skin.color_1_bg = skinModel.color1Bg
        skin.color_1_text = skinModel.color1Text
        skin.color_2_bg = skinModel.color2Bg
        skin.color_2_text = skinModel.color2Text
        skin.color_neutral_bg = skinModel.colorNeutralBg
        skin.color_neutral_text = skinModel.colorNeutralText
        skin.logo_href = skinModel.logoHref
        skin.background_href = skinModel.backgroundHref

        do {
            try context.save()
            print("✅ Skin saved.")
        } catch {
            print("❌ Failed to save skin: \(error.localizedDescription)")
        }
    }

    func fetchDataAndPostToServer(completionBlock: @escaping (Bool, Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let context = self.managedObjectContext else {
                DispatchQueue.main.async {
                    completionBlock(false, NSError(domain: "CoreData", code: -1, userInfo: [NSLocalizedDescriptionKey: "Managed Object Context is nil"]))
                }
                return
            }
            
            let qr = self.fetchSeatsQr(context: context)
            let seats = self.fetchSeats(context: context)
            let products = self.fetchProducts(context: context)
            let dbCode = self.fetchDbCodeFromCoreData()
            
            guard let dbCode = dbCode else {
                DispatchQueue.main.async {
                    completionBlock(false, NSError(domain: "CoreData", code: -2, userInfo: [NSLocalizedDescriptionKey: "DB Code is missing"]))
                }
                return
            }
            
            let postData: [String: Any] = [
                "db_code": dbCode,
                "data": [
                    "seats": qr,
                    "seatBarcodes": self.extractSeatBarcodes(from: seats),
                    "products": self.extractProductQRCodes(from: products)
                ]
            ]
            
            IQAPIClient.uploadAllOfflineData(code: self.savedShowCode ?? "36060-5E56", data: postData) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        print(response)
                        self.deleteAllRecords()
                        completionBlock(true, nil)
                    case .failure(let error):
                        print(error)
                        completionBlock(false, error)
                    }
                }
            }
        }
    }

        
    private func fetchSeatsQr(context: NSManagedObjectContext) -> [String] {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        do {
            let seats = try context.fetch(fetchRequest)
            
            return seats.compactMap { seat in
                guard let qrCode = seat.qrCode, !qrCode.isEmpty,
                      let dateScanned = seat.date_scanned else { return nil } 
                
                let dateScannedTimestamp = Int(dateScanned.timeIntervalSince1970)
                return "\(qrCode)-\(dateScannedTimestamp)"
            }
        } catch {
            print("Error fetching seats: \(error.localizedDescription)")
            return []
        }
    }

    
    private func fetchSeats(context: NSManagedObjectContext) -> [[String: Any]] {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        do {
            let seats = try context.fetch(fetchRequest)
            return seats.map { seat in
                guard let dateScanned = seat.date_scanned else { return ["" : ""] }
                return [
                    "id": seat.oid as Any,
                    "secRowSeat": "\(seat.section ?? "")-\(seat.row ?? "")-\(seat.seat ?? "")",
                    "barcode": seat.barcode ?? "",
                    "qrCode": seat.qrCode ?? "",
                    "handicap": seat.handicapped ?? false,
                    "order": seat.order_id ?? "",
                    "date_Scanned": dateScanned
                ]
            }
        } catch {
            print("Error fetching seats: \(error.localizedDescription)")
            return []
        }
    }
    
    
    private func fetchProducts(context: NSManagedObjectContext) -> [[String: Any]] {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        do {
            let products = try context.fetch(fetchRequest)
            return products.map { product in
                guard let dateScanned = product.date_scanned else { return ["" : ""] }
                return [
                    "name": product.name ?? "",
                    "variantName": product.variantName ?? "",
                    "qrCode": product.qrCode ?? "", 
                    "qty": product.qty,
                    "qty_scanned": product.qty_scanned,
                    "icon_src": product.icon_src ?? "",
                    "order": product.order?.oid ?? "",
                    "date_Scanned": dateScanned
                ]
            }
        } catch {
            print("❌ Error fetching products: \(error.localizedDescription)")
            return []
        }
    }

    
    private func extractSeatBarcodes(from seats: [[String: Any]]) -> [String] {
        return seats.compactMap { seat in
            guard let barcode = seat["barcode"] as? String, !barcode.isEmpty,
                  let dateScanned = seat["date_Scanned"] as? Date else { return nil }
            
            let dateScannedTimestamp = Int(dateScanned.timeIntervalSince1970)
            return "\(barcode)-\(dateScannedTimestamp)"
        }
    }
    
    private func extractProductQRCodes(from products: [[String: Any]]) -> [String] {
        return products.compactMap { product in
            guard let qrCode = product["qrCode"] as? String, !qrCode.isEmpty,
                  let dateScanned = product["date_Scanned"] as? Date else { return nil }
            
            let dateScannedTimestamp = Int(dateScanned.timeIntervalSince1970)
            return "\(qrCode)-\(dateScannedTimestamp)" 
        }
    }


    private func fetchDbCodeFromCoreData() -> String? {
        let fetchRequest: NSFetchRequest<Show> = Show.fetchRequest()
        if let show = try? managedObjectContext?.fetch(fetchRequest).first {
            return show.db_code
        }
        return nil
    }
}
