//
//  LookupByNameResultViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 17/02/25.
//

import SwiftUI
import IQAPIClient
import CoreData

//class LookupByNameResultViewModel: ObservableObject {
//    @Published var orders: [OrdersNewApi] = []
//    @Published var buyerName: String = ""
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    @Published var products: [Product] = []
//    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
//    @AppStorage("isMerchandise") private var isMerchandise: Bool?
//
//    private var managedObjectContext: NSManagedObjectContext
//    
//    init(managedObjectContext: NSManagedObjectContext) {
//        self.managedObjectContext = managedObjectContext
//    }
//    
//    func fetchSeats(c: String, q: String) async {
//        
//        DispatchQueue.main.async {
//            self.isLoading = true
//            self.errorMessage = nil
//        }
//        
//        if isOfflineMode {
//            if isMerchandise ?? false {
//                fetchProducts(orderId: Int(q) ?? 0)
//            }
//            fetchOrdersFromCoreData(orderName: q)
//            return
//        }
//        
//        do {
//            let fetchedOrders = try await withCheckedThrowingContinuation { continuation in
//                IQAPIClient.getLookUpByName(code: c, orderName: q) { result in
//                    switch result {
//                    case .success(let response):
//                        continuation.resume(returning: response)
//                    case .failure(let error):
//                        continuation.resume(throwing: error)
//                    }
//                }
//            }
//            
//            DispatchQueue.main.async {
//                if fetchedOrders.isEmpty {
//                } else {
//                    self.orders = fetchedOrders
//                    print("online",self.orders.count)
//                    
//                }
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
//    
//    func fetchOrdersFromCoreData(orderName: String) {
//        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "buyer_name CONTAINS[cd] %@", orderName)
//        
//        do {
//            let fetchedOrders = try managedObjectContext.fetch(fetchRequest)
//            
//            if !fetchedOrders.isEmpty {
//                let mappedOrders = fetchedOrders.map { order in
//                    return OrdersNewApi(
//                        buyerName: order.buyer_name ?? "",
//                        cc: order.cc ?? "",
//                        phone: order.phone ?? "",
//                        orderId: order.oid?.intValue ?? 0, valid: true, message: "",
//                        seats: [SeatModel(section: "", row: "", seat: "", barcode: "", qrCode: "", qr: Qr(seat: [""]))],
//                        merch: [Merchandise(name: "", variantName: "", qty: 0, icon: "", message: "", qr: QrMerchandise(merch: [""]), tsScanned: 0)]
//                    )
//                }
//                
//                DispatchQueue.main.async {
//                    self.orders = mappedOrders
//                    print("ofline",self.orders.count)
//                    self.errorMessage = nil
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.errorMessage = "No order found in Core Data for name \(orderName)"
//                }
//            }
//        } catch {
//            DispatchQueue.main.async {
//                self.errorMessage = "Error fetching from Core Data: \(error.localizedDescription)"
//            }
//        }
//    }
//    
//    func fetchProducts(orderId: Int) {
//            let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "order_id == %@", NSNumber(value: orderId))
//            
//            do {
//                let fetchedProducts = try managedObjectContext.fetch(fetchRequest)
//                DispatchQueue.main.async {
//                    self.products = fetchedProducts
//                }
//            } catch {
//                print("Error fetching products: \(error)")
//            }
//        }
//}

import SwiftUI
import IQAPIClient
import CoreData

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
    
    func fetchSeats(c: String, q: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
            self.orders = []
        }

        if isOfflineMode {
            if isMerchandise ?? false {
                fetchProducts(orderId: Int(q) ?? 0)
            }
            fetchOrdersFromCoreData(orderName: q)
            return
        }

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
                    self.errorMessage = "Order not found"
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
    
    func fetchOrdersFromCoreData(orderName: String) {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "buyer_name CONTAINS[cd] %@", orderName)
        
        do {
            let fetchedOrders = try managedObjectContext.fetch(fetchRequest)
            
            if !fetchedOrders.isEmpty {
                let mappedOrders = fetchedOrders.map { order in
                    return OrdersNewApi(
                        buyerName: order.buyer_name ?? "",
                        cc: order.cc ?? "",
                        phone: order.phone ?? "",
                        orderId: order.oid?.intValue ?? 0,
                        valid: true,
                        message: "",
                        seats: [SeatModel(section: "", row: "", seat: "", barcode: "", qrCode: "", qr: Qr(seat: [""]))],
                        merch: [Merchandise(name: "", variantName: "", qty: 0, icon: "", message: "", qr: QrMerchandise(merch: [""]), tsScanned: 0)]
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
    
    func fetchProducts(orderId: Int) {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "order_id == %@", NSNumber(value: orderId))
        
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
