//
//  LookupByCreditCardResultViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/02/25.
//


import SwiftUI
import IQAPIClient
import CoreData

class LookupByCreditCardResultViewModel: ObservableObject {
    @Published var orders: [OrdersNewApi] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var managedObjectContext: NSManagedObjectContext
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    // MARK: - Main Functionality
    
    /// Fetches seats/orders using credit card number.
    /// - Parameters:
    ///   - c: An API code or event code passed to the backend
    ///   - q: The credit card number to look up
    func fetchSeats(c: String, q: String) async {
        
        // Start loading and reset error message
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        // Handle Offline Mode: Fetch from Core Data if offline
        if isOfflineMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.fetchCCFromCoreData(ccNumber: q)
                self.isLoading = false
            }
            return
        }
        
        // Handle Online Mode: Fetch from API
        do {
            let fetchedSeats = try await withCheckedThrowingContinuation { continuation in
                IQAPIClient.getLookUpByCreditCard(code: c, ccNumber: q) { result in
                    switch result {
                    case .success(let user):
                        continuation.resume(returning: user)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            // Update the UI on the main thread with fetched data
            DispatchQueue.main.async {
                self.orders = fetchedSeats
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                if NetworkMonitor.shared.isNetworkAvailable() {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.errorMessage = StringManager.shared.strings.noInternet.description
                }
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Core Data Helper
    
    /// Fetches orders by credit card number from Core Data (offline mode).
    /// - Parameter ccNumber: The credit card number to search for
    private func fetchCCFromCoreData(ccNumber: String) {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "cc CONTAINS[cd] %@", ccNumber)
        
        do {
            // Fetch matching orders from local Core Data store
            let fetchedOrders = try managedObjectContext.fetch(fetchRequest)
            
            // Convert Core Data objects to API model objects
            let mappedOrders = fetchedOrders.map { order in
                return OrdersNewApi(
                    buyerName: order.buyerName ?? "",
                    cc: order.cc ?? "",
                    phone: order.phone ?? "",
                    orderId: order.orderId?.intValue ?? 0, valid: true, goldenTicketText: "", isGoldenTicket: nil, message: "",
                    seats: [],
                    merch: []
                )
            }
            
            // Update UI with results
            DispatchQueue.main.async {
                self.orders = mappedOrders
                self.errorMessage = mappedOrders.isEmpty ? "No orders found in Core Data." : nil
            }
            
        } catch {
            // Handle Core Data fetch errors
            DispatchQueue.main.async {
                self.errorMessage = "Error fetching from Core Data: \(error.localizedDescription)"
            }
        }
    }
}
