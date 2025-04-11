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
                  self.buyerName = fetchedOrder.first?.buyerName?.uppercased() ?? "No orders found"
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
        DispatchQueue.main.async {
            self.isLoading = true
        }

        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "oid == %@", orderNumber)
        let seatRelationshipKey = "seats"
        fetchRequest.relationshipKeyPathsForPrefetching = [seatRelationshipKey]

        do {
            let fetchedOrders = try managedObjectContext.fetch(fetchRequest)

            DispatchQueue.main.async {
                if let firstOrder = fetchedOrders.first {

                    self.buyerName = firstOrder.buyer_name?.uppercased() ?? "UNKNOWN BUYER"

                    let seats = firstOrder.seats?.compactMap { seat in
                        SeatModel(
                            section: seat.section ?? "",
                            row: seat.row ?? "",
                            seat: seat.seat ?? "",
                            barcode: seat.barcode,
                            qrCode: seat.qrCode,
                            qr: seat.qrCode != nil ? Qr(seat: [seat.qrCode!]) : nil,
                            tsScanned: Int(seat.date_scanned?.description ?? "0")
                        )
                    } ?? []

                    self.seatsModel = seats
                    self.orders = [OrdersNewApi(
                        buyerName: firstOrder.buyer_name ?? "",
                        cc: firstOrder.cc ?? "",
                        phone: firstOrder.phone ?? "",
                        orderId: firstOrder.oid?.intValue ?? 0,
                        valid: true,
                        message: "",
                        seats: seats,
                        merch: []
                    )]
                } else {

                    self.buyerName = "No orders found"
                    self.errorMessage = "No order found in Core Data for order number \(orderNumber)"
                }
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error fetching from Core Data: \(error.localizedDescription)"
                self.buyerName = "No orders found"
                self.isLoading = false
            }
        }
    }

}
