//
//  LookupByNameResultViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 17/02/25.
//

import SwiftUI
import IQAPIClient
import CoreData

/// ViewModel for performing lookup by buyer name, supporting both online and offline modes.
class LookupByNameResultViewModel: ObservableObject {
    @Published var orders: [OrdersNewApi] = []
    @Published var buyerName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var products: [Product] = []
    
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("isMerchandise") private var isMerchandise: Bool?

    private var managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.orders = []
    }
    
    /// Fetch orders by buyer name, from API (online) or Core Data (offline)
    /// - Parameters:
    ///   - c: Show code
    ///   - q: Buyer name (query string)
    func fetchSeats(c: String, q: String) async {
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
            self.orders = []
        }

        // Handle offline mode
        if isOfflineMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.isMerchandise ?? false {
                    self.fetchProducts(orderId: Int(q) ?? 0)
                }
                self.fetchOrdersFromCoreData(orderName: q)
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
                return
        }

        // Online API call using async continuation
        do {
            let fetchedOrders = try await withCheckedThrowingContinuation { continuation in
                IQAPIClient.getLookUpByName(code: c, orderName: q) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }

            DispatchQueue.main.async {
                if fetchedOrders.isEmpty {
                    self.errorMessage = StringManager.shared.strings?.searchResults.phoneNumber ?? StringConstants.Common.ordersNotFound
                } else {
                    self.orders = fetchedOrders
                    print("online", self.orders.count)
                }
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error: \(error.localizedDescription)"
                self.isLoading = false
                self.orders = []
            }
        }
    }
    
    // MARK: - Core Data: Fetch Orders
    
    /// Fetch orders from local Core Data by buyer name (used in offline mode)
    /// - Parameter orderName: Buyer name string
    func fetchOrdersFromCoreData(orderName: String) {
        
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "buyerName CONTAINS[cd] %@", orderName)
        
        do {
            let fetchedOrders = try managedObjectContext.fetch(fetchRequest)
            
            if !fetchedOrders.isEmpty {
                
                // Map Core Data `Order` to API-like `OrdersNewApi` model
                let mappedOrders = fetchedOrders.map { order in
                    return OrdersNewApi(
                        buyerName: order.buyerName ?? "",
                        cc: order.cc ?? "",
                        phone: order.phone ?? "",
                        orderId: order.orderId?.intValue ?? 0,
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
                    print("offline", self.orders.count)
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
    
    // MARK: - Core Data: Fetch Products
    
    /// Fetch products associated with a given order (used in offline mode for merchandise)
    /// - Parameter orderId: Order ID to filter merchandise
    func fetchProducts(orderId: Int) {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "orderId == %@", NSNumber(value: orderId))
        
        do {
            let fetchedProducts = try managedObjectContext.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.products = fetchedProducts
            }
        } catch {
            print("Error fetching products: \(error)")
        }
    }
}
