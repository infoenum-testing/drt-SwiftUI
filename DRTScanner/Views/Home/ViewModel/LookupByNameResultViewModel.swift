//
//  LookupByNameResultViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 17/02/25.
//


import SwiftUI
import IQAPIClient

class LookupByNameResultViewModel: ObservableObject {
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
            let fetchedSeats = try await withCheckedThrowingContinuation { continuation in
                IQAPIClient.getLookUpByName(code: c, orderName: q) { result in
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
