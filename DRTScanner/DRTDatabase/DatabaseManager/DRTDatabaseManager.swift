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
    
    // MARK: - Sync Method
    
    /// Syncs server data with local Core Data storage.
    /// - Deletes existing records
    /// - Inserts show, orders, seats, and products
    /// - Links orders to seats/products
    /// - Tracks progress and calls completion on main thread
    
    func syncServerData(serverDict: [String: Any], progressBlock: ((Float) -> Void)?, completionBlock: ((Bool, Error?) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            guard let context = self.managedObjectContext else {
                DispatchQueue.main.async { completionBlock?(false, NSError(domain: "CoreData", code: -1, userInfo: [NSLocalizedDescriptionKey: "Managed Object Context is nil"])) }
                return
            }
            
            self.deleteAllRecords()
            
            // Insert or update the Show entity
            guard let show = self.insertUpdateShowRecord(showAttributes: serverDict, context: context) else {
                DispatchQueue.main.async { completionBlock?(false, NSError(domain: "CoreData", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to insert show"])) }
                return
            }
            // Extract orders, seats, and products
            let orders = serverDict["orders"] as? [[String: Any]] ?? []
            let seats = serverDict["seats"] as? [[String: Any]] ?? []
            let products = serverDict["products"] as? [[String: Any]] ?? []
            
            let totalRecords = Float(orders.count + seats.count + products.count)
            var processedRecords: Float = 0
            
            // Temporary dictionary for looking up Orders by ID
            var orderDict: [Int64: Order] = [:]
            
            // Insert/update orders
            for orderData in orders {
                context.performAndWait {
                    if let order = self.insertUpdateOrderRecord(orderAttributes: orderData, context: context) {
                        order.show = show
                        if let orderIdNum = order.orderId?.int64Value {
                            orderDict[orderIdNum] = order
                        }
                    }
                }
                processedRecords += 1
                DispatchQueue.main.async { progressBlock?(processedRecords / totalRecords) }
                do {
                    try context.save()
                } catch {
                    print("Order save error: \(error.localizedDescription)")
                }
                usleep(50000) // 0.05 seconds delay
            }
            
            for seatDict in seats {
                context.performAndWait {
                    if let seat = self.insertSeatRecord(seatAttributes: seatDict, context: context) {
                        seat.show = show
                        // Normalize orderId to Int64 for lookup
                        var orderIdInt64: Int64? = nil
                        if let orderId = seatDict["order"] as? NSNumber {
                            orderIdInt64 = orderId.int64Value
                        } else if let orderId = seatDict["order"] as? Int {
                            orderIdInt64 = Int64(orderId)
                        } else if let orderId = seatDict["order"] as? String, let orderIdVal = Int64(orderId) {
                            orderIdInt64 = orderIdVal
                        }
                        if let orderIdInt64 = orderIdInt64, let linkedOrder = orderDict[orderIdInt64] {
                            seat.order = linkedOrder
                        }
                        do {
                            try context.save()
                        } catch {
                            print("Seat save error: \(error.localizedDescription)")
                        }
                        usleep(50000) // 0.05 seconds delay
                    }
                }
                processedRecords += 1
                DispatchQueue.main.async { progressBlock?(processedRecords / totalRecords) }
            }
            
            for productDict in products {
                context.performAndWait {
                    if let product = self.insertProductRecord(productAttributes: productDict, context: context) {
                        product.show = show
                        // Normalize orderId to Int64 for lookup
                        var orderIdInt64: Int64? = nil
                        if let orderId = productDict["orderId"] as? NSNumber {
                            orderIdInt64 = orderId.int64Value
                        } else if let orderId = productDict["orderId"] as? Int {
                            orderIdInt64 = Int64(orderId)
                        } else if let orderId = productDict["orderId"] as? String, let orderIdVal = Int64(orderId) {
                            orderIdInt64 = orderIdVal
                        }
                        if let orderIdInt64 = orderIdInt64, let linkedOrder = orderDict[orderIdInt64] {
                            product.order = linkedOrder
                        }
                    }
                }
                processedRecords += 1
                DispatchQueue.main.async { progressBlock?(processedRecords / totalRecords) }
                do {
                    try context.save()
                } catch {
                    print("Product save error: \(error.localizedDescription)")
                }
                usleep(50000) // 0.05 seconds delay
            }
            
            do {
                try context.save()
                DispatchQueue.main.async { completionBlock?(true, nil) }
            } catch {
                DispatchQueue.main.async { completionBlock?(false, error) }
            }
        }
    }
    
    // MARK: - Record Deletion
    
    /// Deletes all records from key entities
    private func deleteAllRecords() {
        deleteAllTableRecords(forEntity: Scan.self)
        usleep(50000) // 0.05 seconds delay
        deleteAllTableRecords(forEntity: Product.self)
        usleep(50000)
        deleteAllTableRecords(forEntity: Seat.self)
        usleep(50000)
        deleteAllTableRecords(forEntity: Order.self)
        usleep(50000)
        deleteAllTableRecords(forEntity: Show.self)
        usleep(50000)
    }
    
    /// Deletes Skin records only
    func deleteSkin() {
        deleteAllTableRecords(forEntity: Skin.self)
    }
    
    /// Generic deletion method for any entity type
    private func deleteAllTableRecords<T: NSManagedObject>(forEntity entity: T.Type) {
        guard let context = managedObjectContext else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: entity))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            usleep(50000) // 0.05 seconds delay
        } catch {
            print("Failed to delete \(entity): \(error.localizedDescription)")
        }
    }
    
    // MARK: - Record Insert/Update
    
    /// Inserts or updates a Show record
    private func insertUpdateShowRecord(showAttributes: [String: Any], context: NSManagedObjectContext) -> Show? {
        let fetchRequest: NSFetchRequest<Show> = Show.fetchRequest()
        if let showId = showAttributes["showId"] as? Int {
            fetchRequest.predicate = NSPredicate(format: "showId == %d", showId)
        }
        
        let show = (try? context.fetch(fetchRequest).first) ?? Show(context: context)
        show.showId = (showAttributes["showId"] as? Int)?.description
        show.studioId = (showAttributes["studioId"] as? Int)?.description
        show.showDt = showAttributes["showDt"] as? String
        show.valid = NSNumber(value: showAttributes["valid"] as? Bool ?? false)
        show.dbCode = showAttributes["dbCode"] as? String
        return show
    }
    
    /// Inserts or updates an Order record
    private func insertUpdateOrderRecord(orderAttributes: [String: Any], context: NSManagedObjectContext) -> Order? {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        if let orderId = orderAttributes["orderId"] as? Int {
            fetchRequest.predicate = NSPredicate(format: "orderId == %d", orderId)
        }
        
        let order = (try? context.fetch(fetchRequest).first) ?? Order(context: context)
        order.orderId = orderAttributes["orderId"] as? NSNumber
        order.buyerName = orderAttributes["buyerName"] as? String
        order.cc = orderAttributes["cc"] as? String
        order.phone = orderAttributes["phone"] as? String
        return order
    }
    
    /// Inserts or updates a Seat record
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
        
        seat.id = seatAttributes["id"] as? NSNumber
        seat.orderId = seatAttributes["order"] as? NSNumber
        seat.barcode = seatAttributes["barcode"] as? String
        seat.qrCode = seatAttributes["qrCode"] as? String
        if let handicapValue = seatAttributes["handicap"] as? Int {
            seat.handicapped = NSNumber(value: handicapValue == 1)
        } else {
            seat.handicapped = NSNumber(value: false)
        }
        
        // Parse scanned time string into Date
        if let tsValue = seatAttributes["tsScanned"] {
            let timestamp: TimeInterval?
            
            if let tsString = tsValue as? String {
                timestamp = TimeInterval(tsString)
            } else if let tsDouble = tsValue as? Double {
                timestamp = TimeInterval(tsDouble)
            } else {
                timestamp = nil
            }
            
            if let timestamp = timestamp {
                let scannedDate = Date(timeIntervalSince1970: timestamp / 1000)
                seat.date_scanned = scannedDate
            }
        }
        
        
        // Split secRowSeat into section, row, seat
        if let secRowSeat = seatAttributes["secRowSeat"] as? String {
            let components = secRowSeat.split(separator: "-")
            if components.count == 3 {
                seat.section = String(components[0])
                seat.row = String(components[1])
                seat.seat = String(components[2])
            }
        }
        
        // Associate seat with order
        if let orderId = seatAttributes["order"] as? Int {
            let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "orderId == %d", orderId)
            context.performAndWait {
                seat.order = try? context.fetch(fetchRequest).first
            }
        }
        
        return seat
    }
    
    /// Inserts a new Product record
    private func insertProductRecord(productAttributes: [String: Any], context: NSManagedObjectContext) -> Product? {
        let product = Product(context: context)
        
        product.name = productAttributes["name"] as? String
        
        if let variant = productAttributes["variantName"], !(variant is NSNull) {
            product.variantName = variant as? String
        } else {
            product.variantName = nil
        }
        
        product.qrCode = productAttributes["qrCode"] as? String
        
        // Set quantity
        if let qty = productAttributes["qty"] as? Int64 {
            product.qty = qty
        } else if let qty = productAttributes["qty"] as? Int {
            product.qty = Int64(qty)
        } else if let qtyStr = productAttributes["qty"] as? String, let qty = Int64(qtyStr) {
            product.qty = qty
        } else {
            product.qty = 0
        }
        
        // Set scanned quantity
        var qtyScanned: Int64 = 0
        if let val = productAttributes["qtyScanned"] as? Int64 {
            qtyScanned = val
        } else if let val = productAttributes["qtyScanned"] as? Int {
            qtyScanned = Int64(val)
        } else if let val = productAttributes["qtyScanned"] as? String, let parsed = Int64(val) {
            qtyScanned = parsed
        }
        
        if !product.isFault && !product.isDeleted {
            product.qtyScanned = qtyScanned
        }
        
        product.iconSrc = productAttributes["iconSrc"] as? String
        
        // Set order ID for linking
        if let orderId = productAttributes["orderId"] as? Int64 {
            product.orderId = orderId
        } else if let orderId = productAttributes["orderId"] as? Int {
            product.orderId = Int64(orderId)
        } else if let orderIdNum = productAttributes["orderId"] as? NSNumber {
            product.orderId = orderIdNum.int64Value
        } else if let orderIdStr = productAttributes["orderId"] as? String, let orderId = Int64(orderIdStr) {
            product.orderId = orderId
        } else {
            product.orderId = 0
        }
        
        if let timestamp = productAttributes["tsScanned"] as? Int64 {
            product.date_scanned = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        } else if let timestamp = productAttributes["tsScanned"] as? Int {
            product.date_scanned = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        } else if let timestamp = productAttributes["tsScanned"] as? Double {
            product.date_scanned = Date(timeIntervalSince1970: timestamp / 1000)
        } else if let timestampStr = productAttributes["tsScanned"] as? String,
                  let timestamp = Double(timestampStr) {
            // Parse scanned time string into Date
            let scannedDate = Date(timeIntervalSince1970: timestamp / 1000)
            product.date_scanned = scannedDate
        } else if let timestampStr = productAttributes["scanned"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            formatter.locale = Locale(identifier: "en_US_POSIX") // ensures consistent parsing
            if let date = formatter.date(from: timestampStr) {
                product.date_scanned = date
            }
        } else  {
            product.date_scanned = nil
        }
        
        return product
    }
    
    // Inserts a new Skin entity or updates the existing one in Core Data using the provided SkinModel
    func insertOrUpdateSkin(skinModel: SkinModel, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Skin> = Skin.fetchRequest()
        
        // Try to fetch existing skin or create a new one
        let skin = (try? context.fetch(fetchRequest).first) ?? Skin(context: context)
        skin.color_Valid = skinModel.colorValid
        skin.color_Invalid = skinModel.colorInvalid
        skin.color_Previous = skinModel.colorPrevious
        skin.color_1_bg = skinModel.color1Bg
        skin.color_1_text = skinModel.color1Text
        skin.color_2_bg = skinModel.color2Bg
        skin.color_2_text = skinModel.color2Text
        skin.color_neutral_bg = skinModel.colorNeutralBg
        skin.color_neutral_text = skinModel.colorNeutralText
        skin.logo_href = skinModel.logoHref
        skin.background_href = skinModel.backgroundHref
        skin.colorButtonBg = skinModel.colorButtonBg
        skin.colorGoldenTicket = skinModel.colorGoldenTicket
        skin.colorButtonText = skinModel.colorButtonText
        skin.colorGrayText = skinModel.colorGrayText
        
        do {
            try context.save()
            print("✅ Skin saved.")
        } catch {
            print("❌ Failed to save skin: \(error.localizedDescription)")
        }
    }
    
    // Fetches offline-scanned data from Core Data and posts it to the server
    func fetchDataAndPostToServer(completionBlock: @escaping (Bool, Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            
            // Ensure Core Data context is available
            guard let context = self.managedObjectContext else {
                DispatchQueue.main.async {
                    completionBlock(false, NSError(domain: "CoreData", code: -1, userInfo: [NSLocalizedDescriptionKey: "Managed Object Context is nil"]))
                }
                return
            }
            
            // Fetch scanned seat QR codes, full seat data, and scanned products
            let qr = self.fetchSeatsQr(context: context)
            let seats = self.fetchSeats(context: context)
            let products = self.fetchProducts(context: context)
            //Here I get multiple QRs joined with || as string inside products
            let dbCode = self.fetchDbCodeFromCoreData()
            
            guard let dbCode = dbCode else {
                DispatchQueue.main.async {
                    completionBlock(false, NSError(domain: "CoreData", code: -2, userInfo: [NSLocalizedDescriptionKey: "DB Code is missing"]))
                }
                return
            }
            
            // Prepare the data to upload
            let postData: [String: Any] = [
                "dbCode": dbCode,
                "data": [
                    "seats": qr,
                    "seatBarcodes": self.extractSeatBarcodes(from: seats),
                    "products": self.extractProductQRCodes(from: products)
                ]
            ]
            
            // Call API to upload data
            IQAPIClient.uploadAllOfflineData(code: self.savedShowCode ?? "36060-5E56", data: postData) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        print(response)
                        // Optionally clear data after successful upload
                        //                        self.deleteAllRecords()
                        completionBlock(true, nil)
                    case .failure(let error):
                        print(error)
                        completionBlock(false, error)
                    }
                }
            }
        }
    }
    
    // Fetches scanned seat QR codes from Core Data, formatted as "<qrCode>-<timestamp>"
    private func fetchSeatsQr(context: NSManagedObjectContext) -> [String] {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        
        do {
            let seats = try context.fetch(fetchRequest)
            
            var extractedQRCodes: [String] = []
            
            for seat in seats {
                guard let qrCode = seat.qrCode, !qrCode.isEmpty,
                      let dateScanned = seat.date_scanned,
                      seat.locally_scanned > 0 else { continue }
                
                let timestamp = Int(dateScanned.timeIntervalSince1970)
                let formattedString = "\(qrCode)-\(timestamp)"
                
                for _ in 0..<seat.locally_scanned {
                    extractedQRCodes.append(formattedString)
                }
            }
            
            return extractedQRCodes
            
        } catch {
            print("Error fetching seats: \(error.localizedDescription)")
            return []
        }
    }
    
    // Fetches detailed seat data from Core Data for upload
    private func fetchSeats(context: NSManagedObjectContext) -> [[String: Any]] {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        do {
            let seats = try context.fetch(fetchRequest)
            return seats.map { seat in
                guard let dateScanned = seat.date_scanned else { return ["" : ""] }
                return [
                    "id": seat.id as Any,
                    "secRowSeat": "\(seat.section ?? "")-\(seat.row ?? "")-\(seat.seat ?? "")",
                    "barcode": seat.barcode ?? "",
                    "qrCode": seat.qrCode ?? "",
                    "locally_scanned": seat.locally_scanned,
                    "handicap": seat.handicapped ?? false,
                    "order": seat.orderId ?? "",
                    "date_Scanned": dateScanned
                ]
            }
        } catch {
            print("Error fetching seats: \(error.localizedDescription)")
            return []
        }
    }
    
    // Fetches detailed product data from Core Data for upload
    func fetchProducts(context: NSManagedObjectContext) -> [[String: Any]] {
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
                    "qty_scanned": product.qtyScanned,
                    "locally_scanned": product.locally_scanned,
                    "icon_src": product.iconSrc ?? "",
                    "order": product.order?.orderId ?? "",
                    "date_Scanned": dateScanned
                ]
            }
        } catch {
            print("❌ Error fetching products: \(error.localizedDescription)")
            return []
        }
    }
    
    // Extracts formatted barcode-timestamp strings from seat data
    private func extractSeatBarcodes(from seats: [[String: Any]]) -> [String] {
        var extractedBarcodes: [String] = []
        
        for seat in seats {
            guard let barcode = seat["barcode"] as? String, !barcode.isEmpty,
                  let dateScanned = seat["date_Scanned"] as? Date,
                  let quantityCount = seat["locally_scanned"] as? Int64, quantityCount > 0 else { continue }
            
            let timestamp = Int(dateScanned.timeIntervalSince1970)
            let formattedBarcode = "\(barcode)-\(timestamp)"
            
            for _ in 0..<quantityCount {
                extractedBarcodes.append(formattedBarcode)
            }
        }
        return extractedBarcodes
    }
    
    // Extracts formatted QRCode-timestamp strings from product data
    private func extractProductQRCodes(from products: [[String: Any]]) -> [String] {
        var extractedQRCodes: [String] = []
        
        for product in products {
            guard let qrCode = product["qrCode"] as? String, !qrCode.isEmpty,
                  let dateScanned = product["date_Scanned"] as? Date,
                  let quantityCount = product["locally_scanned"] as? Int64 else { continue }
            
            let timestamp = Int(dateScanned.timeIntervalSince1970)
            let fullString = "\(qrCode)-\(timestamp)"
            
            for _ in 0..<quantityCount {
                extractedQRCodes.append(fullString)
            }
        }
        
        return extractedQRCodes
    }
    
    // Fetches the db_code value from the stored Show object in Core Data
    private func fetchDbCodeFromCoreData() -> String? {
        let fetchRequest: NSFetchRequest<Show> = Show.fetchRequest()
        if let show = try? managedObjectContext?.fetch(fetchRequest).first {
            return show.dbCode
        }
        return nil
    }
    
    func saveScannedSeat(barcode: String, qrCode: String, isScannedOut: Bool, timeStamp: NSNumber) {
        guard let context = self.managedObjectContext else { return }
        context.performAndWait {
            let scan = Scan(context: context)
            scan.barcode = barcode
            scan.qrCode = qrCode
            scan.is_scanned_out = NSNumber(value: isScannedOut)
            scan.timeStamp = timeStamp
            do {
                try context.save()
                print("✅ Scan saved.")
            } catch {
                print("❌ Failed to save scan: \(error.localizedDescription)")
            }
        }
    }
}

// Removes all associated seats from the given order object
func clearOrderSeats(order: Order) {
    let seatsToRemove = Array(order.seats ?? [])
    for seat in seatsToRemove {
        order.removeFromSeats(seat)
    }
}
