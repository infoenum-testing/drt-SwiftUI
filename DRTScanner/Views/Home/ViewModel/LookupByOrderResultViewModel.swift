//
//  LookupByOrderResultViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 10/02/25.
//

import SwiftUI
import IQAPIClient
import CoreData

class LookupByOrderResultViewModel: ObservableObject {
    @Published var orders: [Orders] = []
    @Published var seatsModel: [SeatModel]?
    @Published var buyerName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func fetchSeats(c: String, q: String) async {
        
      
        DispatchQueue.main.async {
            self.orders = []
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let fetchedOrder: OrderModel = try await withCheckedThrowingContinuation { continuation in
                IQAPIClient.getLookUpByOrder(code: c, orderNumber: q) { result in
                    switch result {
                    case .success(let orderData):
                        continuation.resume(returning: orderData)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.buyerName = fetchedOrder.orders?.first?.buyerName?.uppercased() ?? "N/A"
            }
            
            guard let orderId = fetchedOrder.orders?.first?.orderId else {
                throw NSError(domain: "OrderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Order ID not found"])
            }
            
            let orderDetail: OrderDetailModel = try await withCheckedThrowingContinuation { continuation in
                IQAPIClient.getOrderDetail(code: c, oId: orderId) { result in
                    switch result {
                    case .success(let detailData):
                        print(detailData)
                        continuation.resume(returning: detailData)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.seatsModel = orderDetail.seats
                self.isLoading = false
            }
            let fetchedSeats = try await withCheckedThrowingContinuation { continuation in
                IQAPIClient.getLookUpByOrder(code: c, orderNumber: q) { result in
                    switch result {
                    case .success(let user):
                        continuation.resume(returning: user.orders ?? [])
                    case .failure(let error):
                        continuation.resume(throwing: error)
                        print(self.errorMessage)
                    }
                }
            }
            
            DispatchQueue.main.async {
                if fetchedSeats.count > 0 {
                    self.orders = fetchedSeats
                }
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                
                self.fetchOrdersFromCoreData(orderNumber: q)
            }
        }
    }
    func fetchOrdersFromCoreData(orderNumber: String) {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "oid == %@", orderNumber)
        
        let seatRelationshipKey = "seats"
        
        fetchRequest.relationshipKeyPathsForPrefetching = [seatRelationshipKey]
        
        do {
            let fetchedOrders = try managedObjectContext.fetch(fetchRequest)
            
            if !fetchedOrders.isEmpty {
                let mappedOrders = fetchedOrders.map { order in
                    
                    let seats = order.seats?.compactMap { seat in
                        return SeatModel(
                            section: seat.section ?? "",
                            row: seat.row ?? "",
                            seat: seat.seat ?? "",
                            barcode: seat.barcode,
                            qrCode: seat.qrCode,
                            qr: seat.qrCode != nil ? Qr(code: seat.qrCode, valid: true) : nil,
                            tsScanned: seat.date_scanned?.description
                        )
                    } ?? []
                    self.seatsModel = seats
                    return Orders(
                        buyerName: order.buyer_name ?? "",
                        cc: order.cc ?? "",
                        phone: order.phone ?? "",
                        orderId: order.oid?.intValue ?? 0,
                        studioId: 0,
                        success: true,
                        message: ""
                    )
                }
                
                DispatchQueue.main.async {
                    self.orders = mappedOrders
                    self.errorMessage = nil
                }
                
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "No order found in Core Data for order number \(orderNumber)"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error fetching from Core Data: \(error.localizedDescription)"
            }
        }
    }
}
