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
    
    func validateCode(_ code: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let result = try await getShowCodeDataAsync(code: code)
            
            //DispatchQueue.main.async{
                print("Received result: \(result)")

//                if let showCode = result.showID {
//                    self.enteredCode = code
//                    self.isValidCode = true
//                    var user = DRTUser()
//                    user.showCode = showCode
//                   // user.setUserInfo(from: result)
//                    DRTUser.currentUser = user
//                } else {
//                    print("DeviceName is missing or not a String.")
//                    self.isValidCode = false
//                }
            //}
        } catch {
            DispatchQueue.main.async {
                self.isValidCode = false
            }
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
            self.showAlert = true
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
