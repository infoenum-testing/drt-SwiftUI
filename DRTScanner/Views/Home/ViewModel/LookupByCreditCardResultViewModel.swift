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
    
    func fetchSeats(c: String, q: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        if isOfflineMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.fetchCCFromCoreData(ccNumber: q)
                self.isLoading = false
            }
            return
        }
        
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
            
            DispatchQueue.main.async {
                self.orders = fetchedSeats
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                //      self.fetchCCFromCoreData(ccNumber: q)
            }
        }
    }
    private func fetchCCFromCoreData(ccNumber: String) {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "cc CONTAINS[cd] %@", ccNumber)
        
        do {
            let fetchedOrders = try managedObjectContext.fetch(fetchRequest)
            
            let mappedOrders = fetchedOrders.map { order in
                return OrdersNewApi(
                    buyerName: order.buyer_name ?? "",
                    cc: order.cc ?? "",
                    phone: order.phone ?? "",
                    orderId: order.oid?.intValue ?? 0, valid: true, goldenTicketText: "", isGoldenTicket: nil, message: "",
                    seats: [],
                    merch: []
                )
            }
            
            DispatchQueue.main.async {
                self.orders = mappedOrders
                self.errorMessage = mappedOrders.isEmpty ? "No orders found in Core Data." : nil
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error fetching from Core Data: \(error.localizedDescription)"
            }
        }
    }
}
