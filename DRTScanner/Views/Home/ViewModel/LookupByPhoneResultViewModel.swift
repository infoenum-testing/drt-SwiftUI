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
    @Published var orders: [Orders] = []
    @Published var seatsModel: [SeatModel] = []
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
            let fetchedSeats = try await withCheckedThrowingContinuation { continuation in
                IQAPIClient.getLookUpByPhone(code: c, phoneNumber: q) { result in
                    switch result {
                    case .success(let user):
                        continuation.resume(returning: user.orders ?? [])
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
                self.fetchphoneFromCoreData(phoneNumber: q)
            }
        }
    }
    private func fetchphoneFromCoreData(phoneNumber: String) {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "phone CONTAINS[cd] %@", phoneNumber)
        
        do {
            let fetchedOrders = try managedObjectContext.fetch(fetchRequest)
            
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
                self.errorMessage = mappedOrders.isEmpty ? "No orders found in Core Data." : nil
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error fetching from Core Data: \(error.localizedDescription)"
            }
        }
    }
}
