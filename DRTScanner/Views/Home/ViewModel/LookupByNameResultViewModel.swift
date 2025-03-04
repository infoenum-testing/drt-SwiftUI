//
//  LookupByNameResultViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 17/02/25.
//


//import SwiftUI
//import IQAPIClient
//
//class LookupByNameResultViewModel: ObservableObject {
//    @Published var orders: [Orders] = []
//    @Published var seatsModel: [SeatModel] = []
//    @Published var buyerName: String = ""
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    
//    func fetchSeats(c: String, q: String) async {
//        DispatchQueue.main.async {
//            self.isLoading = true
//            self.errorMessage = nil
//        }
//        
//        do {
//            let fetchedSeats = try await withCheckedThrowingContinuation { continuation in
//                IQAPIClient.getLookUpByName(code: c, orderName: q) { result in
//                    switch result {
//                    case .success(let user):
//                        continuation.resume(returning: user.orders ?? [])
//                    case .failure(let error):
//                        continuation.resume(throwing: error)
//                    }
//                }
//            }
//            
//            DispatchQueue.main.async {
//                self.orders = fetchedSeats
//                self.isLoading = false
//            }
//            
//        } catch {
//            DispatchQueue.main.async {
//                self.errorMessage = error.localizedDescription
//                self.isLoading = false
//            }
//        }
//    }
//}

import SwiftUI
import IQAPIClient
import CoreData

class LookupByNameResultViewModel: ObservableObject {
    @Published var orders: [Orders] = []
    @Published var buyerName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func fetchSeats(c: String, q: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let fetchedOrders = try await withCheckedThrowingContinuation { continuation in
                IQAPIClient.getLookUpByName(code: c, orderName: q) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response.orders ?? [])
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            DispatchQueue.main.async {
                if fetchedOrders.isEmpty {
                    self.fetchOrdersFromCoreData(orderName: q) // Fetch from Core Data if API returns empty
                } else {
                    self.orders = fetchedOrders
                    print("online",self.orders.count)
                    
                }
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                self.fetchOrdersFromCoreData(orderName: q) // Fetch from Core Data if API fails
            }
        }
    }
    
    func fetchOrdersFromCoreData(orderName: String) {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "buyer_name CONTAINS[cd] %@", orderName)
        
        do {
            let fetchedOrders = try managedObjectContext.fetch(fetchRequest)
            
            if !fetchedOrders.isEmpty {
                let mappedOrders = fetchedOrders.map { order in
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
                    print("ofline",self.orders.count)
                    self.errorMessage = nil
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "No order found in Core Data for name \(orderName)"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error fetching from Core Data: \(error.localizedDescription)"
            }
        }
    }
}
