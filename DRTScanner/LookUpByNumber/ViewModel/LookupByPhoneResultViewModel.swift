//
//  LookupByPhoneResultViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 17/02/25.
//


import SwiftUI
import IQAPIClient
import CoreData

class LookupByPhoneResultViewModel: ObservableObject {
    @Published var orders: [OrdersNewApi] = []
    @Published var seatsModel: [SeatModel] = []
    @Published var buyerName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    
    private var managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    // Fetch seats/orders by phone number, either from API or Core Data depending on offline mode
    func fetchSeats(c: String, q: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        if isOfflineMode {
            // If offline, fetch from Core Data after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.fetchphoneFromCoreData(phoneNumber: q)
                self.isLoading = false
            }
            return
        }
        
        do {
            // Fetch from API using IQAPIClient
            let fetchedSeats = try await withCheckedThrowingContinuation { continuation in
                IQAPIClient.getLookUpByPhone(code: c, phoneNumber: q) { result in
                    switch result {
                    case .success(let user):
                        continuation.resume(returning: user)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.orders = fetchedSeats
                self.isLoading = false
            }
            
        } catch {
            // On error, show error message and fallback to Core Data
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                self.fetchphoneFromCoreData(phoneNumber: q)
            }
        }
    }
    
    // Fetch orders from Core Data by phone number
    private func fetchphoneFromCoreData(phoneNumber: String) {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "phone CONTAINS[cd] %@", phoneNumber)
        
        do {
            let fetchedOrders = try managedObjectContext.fetch(fetchRequest)
            
            // Map Core Data Order objects to OrdersNewApi model
            let mappedOrders = fetchedOrders.map { order in
                return OrdersNewApi(
                    buyerName: order.buyer_name ?? "",
                    cc: order.cc ?? "",
                    phone: order.phone ?? "",
                    orderId: order.oid?.intValue ?? 0,
                    valid: true,
                    goldenTicketText: "",
                    isGoldenTicket: nil,
                    message: "",
                    seats: [],
                    merch: []
                )
            }
            
            DispatchQueue.main.async {
                self.orders = mappedOrders
                self.errorMessage = mappedOrders.isEmpty ? "No orders found in Core Data." : nil
            }
            
        } catch {
            // Handle Core Data fetch error
            DispatchQueue.main.async {
                self.errorMessage = "Error fetching from Core Data: \(error.localizedDescription)"
            }
        }
    }
}
