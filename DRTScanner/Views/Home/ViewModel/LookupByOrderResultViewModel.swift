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
    @Published var orders: [OrdersNewApi] = []
    @Published var seatsModel: [SeatModel]?
    @Published var merchModel: [Merchandise]?
    @Published var buyerName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isValid: Bool = false

    private var managedObjectContext: NSManagedObjectContext
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("showId") private var savedShowId: String?
    @AppStorage("isMerchandise") private var isMerchandise: Bool?
    
      init(managedObjectContext: NSManagedObjectContext) {
          self.managedObjectContext = managedObjectContext
      }
      
      func fetchSeats(c: String, q: String) async {

          DispatchQueue.main.async {
              self.orders = []
              self.isLoading = true
              self.errorMessage = nil
          }
          
          if isOfflineMode {
              fetchOrdersFromCoreData(orderNumber: q)
              return
          }
          
          do {
              let fetchedOrder: [OrdersNewApi] = try await withCheckedThrowingContinuation { continuation in
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
                  self.buyerName = fetchedOrder.first?.buyerName?.uppercased() ?? "N/A"
              }
              
              guard let orderId = fetchedOrder.first?.orderId else {
                  throw NSError(domain: "OrderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Order ID not found"])
              }
              
              let type = isMerchandise ?? false ? "merch" : "seats"
              let orderDetail: OrdersNewApi = try await withCheckedThrowingContinuation { continuation in
                  IQAPIClient.getOrderDetail(code: c, sid: savedShowId ?? "", oId: orderId, type: type) { result in
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
                  if self.isMerchandise ?? false {
                      self.merchModel = orderDetail.merch
                  } else {
                      self.seatsModel = orderDetail.seats
                  }
                  self.isLoading = false
              }
              let fetchedSeats = try await withCheckedThrowingContinuation { continuation in
                  IQAPIClient.getLookUpByOrder(code: c, orderNumber: q) { result in
                      switch result {
                      case .success(let user):
                          continuation.resume(returning: user)
                      case .failure(let error):
                          continuation.resume(throwing: error)
                          print(self.errorMessage ?? "")
                      }
                  }
              }
              
              DispatchQueue.main.async {
                  self.orders = fetchedSeats
                  self.isLoading = false
              }
              
          } catch {
              DispatchQueue.main.async {
                  self.errorMessage = error.localizedDescription
                  self.isLoading = false
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
                            qr: seat.qrCode != nil ? Qr(seat: seat.qrCode != nil ? [seat.qrCode!] : []) : nil,
                            tsScanned: Int(seat.date_scanned?.description ?? "0")
                        )
                    } ?? []
                    self.seatsModel = seats
                    return OrdersNewApi(
                        buyerName: order.buyer_name ?? "",
                        cc: order.cc ?? "",
                        phone: order.phone ?? "",
                        orderId: order.oid?.intValue ?? 0, valid: true, message: "",
                        seats: [SeatModel(section: "", row: "", seat: "", barcode: "", qrCode: "", qr: Qr(seat: [""]))],
                        merch: [Merchandise(name: "", variantName: "", qty: 0, icon: "", message: "", qr: QrMerchandise(merch: [""]), tsScanned: 0)]
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
