//
//  LandingViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 04/02/25.
//

import Foundation
import SwiftUI
import IQAPIClient
import CoreData

// ViewModel for handling landing screen logic
class LandingViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isValidCode: Bool = true
    // Stores the code entered by the user
    @Published var enteredCode: String = ""
    @Published var showAlert: Bool = false
    // Stores the last successfully validated show code
    @AppStorage("showCode") private var savedShowCode: String?
    // Stores the last successfully validated show ID
    @AppStorage("showId") private var savedShowId: String?
    // Stores the last successfully validated show date/time
    @AppStorage("show") private var savedShow: String?
    // Tracks if the user is logged in
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    
    // Validates the entered code asynchronously, updates state and saves data if valid
    func validateCode(_ code: String, context: NSManagedObjectContext) async {
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
            // If skin data is present, update or insert it in the database
            if let skinDict = result.skin {
                DRTDatabaseManager.shared.insertOrUpdateSkin(skinModel: skinDict, context: context)
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
    
    // Asynchronously fetches show code data from the API and returns a DRTUser object
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
