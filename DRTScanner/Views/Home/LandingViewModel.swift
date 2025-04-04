//
//  LandingViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 04/02/25.
//

import Foundation
import SwiftUI
import IQAPIClient

class LandingViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isValidCode: Bool = true
    @Published var enteredCode: String = ""
    @Published var showAlert: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    @AppStorage("showId") private var savedShowId: String?
    @AppStorage("show") private var savedShow: String?
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    
    func validateCode(_ code: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let result = try await getShowCodeDataAsync(code: code)
            print("Received result: \(result)")
            DispatchQueue.main.async {
                self.isValidCode = true
                self.savedShowCode = code
                self.savedShowId = result.showId
                self.savedShow = result.showDt
                self.isUserLoggedIn = true
                self.showAlert = false
            }
        } catch {
            DispatchQueue.main.async {
                self.isValidCode = false
                self.showAlert = true
                self.isUserLoggedIn = false
            }
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func getShowCodeDataAsync(code: String) async throws -> DRTUser {
        return try await withCheckedThrowingContinuation { continuation in
            IQAPIClient.getShowCodeData(code: code) { result in
                switch result {
                case .success(let user):
                    continuation.resume(returning: user)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
