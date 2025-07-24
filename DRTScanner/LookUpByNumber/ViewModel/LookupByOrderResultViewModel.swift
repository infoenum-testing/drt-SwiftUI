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
      
    // Function to fetch order details (seats/merchandise) either from Core Data or from the API
      func fetchSeats(c: String, q: String) async {
          
          // Show loading spinner and reset previous error or orders
          DispatchQueue.main.async {
              self.orders = []
              self.isLoading = true
              self.errorMessage = nil
          }
          
          // If offline mode is enabled, fetch orders from Core Data
          if isOfflineMode {
              fetchOrdersFromCoreData(orderNumber: q)
              return
          }
          
          do {
              // Fetch order details from the API
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
              
              // Set the buyer's name fetched from the API
              DispatchQueue.main.async {
                  self.buyerName = fetchedOrder.first?.buyerName?.uppercased() ?? "No orders found"
              }
              
              // Ensure orderId is present, throw error if not found
              guard let orderId = fetchedOrder.first?.orderId else {
                  throw NSError(domain: "OrderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Order ID not found"])
              }
              
              // Determine whether to fetch seats or merchandise based on the flag
              let type = isMerchandise ?? false ? "merch" : "seats"
              
              // Fetch detailed order info (either seats or merchandise) from the API
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
              
              // Update the UI with fetched data
              DispatchQueue.main.async {
                  if self.isMerchandise ?? false {
                      self.merchModel = orderDetail.merch
                  } else {
                      self.seatsModel = orderDetail.seats
                  }
                  self.isLoading = false
              }
              
              // Fetch the same order again (seats data) to update the orders list
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
              
              // Update the UI with fetched seats
              DispatchQueue.main.async {
                  self.orders = fetchedSeats
                  self.isLoading = false
              }
              
          } catch {
              DispatchQueue.main.async {
                  if NetworkMonitor.shared.isNetworkAvailable() {
                      self.errorMessage = error.localizedDescription
                  } else {
                      self.errorMessage = StringManager.shared.strings?.noInternet.description ?? StringConstants.Common.noInternetError
                  }
                  self.isLoading = false
              }
          }
      }
    
    // Function to fetch orders from Core Data based on the order number
    func fetchOrdersFromCoreData(orderNumber: String) {
        DispatchQueue.main.async {
            self.isLoading = true
        }

        // If orders are found, map them to the OrdersNewApi format and update the UI
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "orderId == %@", orderNumber)
        let seatRelationshipKey = "seats"
        fetchRequest.relationshipKeyPathsForPrefetching = [seatRelationshipKey]

        do {
            let fetchedOrders = try managedObjectContext.fetch(fetchRequest)

            DispatchQueue.main.async {
                if let firstOrder = fetchedOrders.first {

                    self.buyerName = firstOrder.buyerName?.uppercased() ?? "UNKNOWN BUYER"
                   
                    // Map seats data from Core Data into SeatModel objects
                    let seats = firstOrder.seats?.compactMap { seat in
                        SeatModel(
                            section: seat.section ?? "",
                            row: seat.row ?? "",
                            seat: seat.seat ?? "",
                            barcode: seat.barcode,
                            qrCode: seat.qrCode,
                            qr: seat.qrCode != nil ? Qr(seat: [seat.qrCode!]) : nil,
                            tsScanned: seat.date_scanned?.description ?? "0"
                        )
                    } ?? []

                    self.seatsModel = seats
                    
                    // Create a mock OrdersNewApi object from the Core Data order and update the orders
                    self.orders = [OrdersNewApi(
                        buyerName: firstOrder.buyerName ?? "",
                        cc: firstOrder.cc ?? "",
                        phone: firstOrder.phone ?? "",
                        orderId: firstOrder.orderId?.intValue ?? 0,
                        valid: true,
                        goldenTicketText: "",
                        isGoldenTicket: nil,
                        message: "",
                        seats: seats,
                        merch: []
                    )]
                } else {

                    self.buyerName = StringManager.shared.strings?.searchResults.resultNotFound ?? "No orders found."
                    self.errorMessage = "No order found in Core Data for order number \(orderNumber)"
                }
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error fetching from Core Data: \(error.localizedDescription)"
                self.buyerName =  StringManager.shared.strings?.searchResults.resultNotFound ?? "No orders found."
                self.isLoading = false
            }
        }
    }

}
