//
//  LookupByOrderResultViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 10/02/25.
//

import SwiftUI
import IQAPIClient

class LookupByOrderResultViewModel: ObservableObject {
    @Published var orders: [Orders] = []
    @Published var seatsModel: [SeatModel] = []
    @Published var buyerName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func fetchSeats(c: String, q: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let fetchedOrder: OrderModel = try await withCheckedThrowingContinuation { continuation in
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
                self.buyerName = fetchedOrder.orders?.first?.buyerName?.uppercased() ?? "N/A"
            }
            
            guard let orderId = fetchedOrder.orders?.first?.orderId else {
                throw NSError(domain: "OrderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Order ID not found"])
            }
            
            let orderDetail: OrderDetailModel = try await withCheckedThrowingContinuation { continuation in
                IQAPIClient.getOrderDetail(code: c, oId: orderId) { result in
                    switch result {
                    case .success(let detailData):
                        continuation.resume(returning: detailData)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.seatsModel = orderDetail.seats
                self.isLoading = false
            }
            let fetchedSeats = try await withCheckedThrowingContinuation { continuation in
                IQAPIClient.getLookUpByOrder(code: c, orderNumber: q) { result in
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
            }
        }
    }
}
