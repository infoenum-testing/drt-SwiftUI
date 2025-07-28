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

class LandingViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isValidCode: Bool = true
    @Published var enteredCode: String = ""
    @Published var showAlert: Bool = false
    @Published var drtUser: DRTUser?
    
    @AppStorage("showCode") private var savedShowCode: String?
    @AppStorage("showId") private var savedShowId: String?
    @AppStorage("show") private var savedShow: String?
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    
    var lookupByOrderResultViewModel: LookupByOrderResultViewModel
    
    init(lookupByOrderResultViewModel: LookupByOrderResultViewModel) {
        self.lookupByOrderResultViewModel = lookupByOrderResultViewModel
        
        let context = PersistenceController.shared.container.viewContext
        let fetch: NSFetchRequest<Skin> = Skin.fetchRequest()
        if let skins = try? context.fetch(fetch), let firstSkin = skins.first,
           let model = SkinModel(skin: firstSkin) {
            ColorManager.shared.updateSkin(to: model)
        }
    }
    
    func validateCode(_ code: String, context: NSManagedObjectContext) async {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let result = try await getShowCodeDataAsync(code: code)
            print("Received result: \(result)")
            if let skin = result.skin {
                ColorManager.shared.updateSkin(to: skin)
            }
            DispatchQueue.main.async {
                self.drtUser = result
            }
            await MainActor.run {
                self.isValidCode = true
                self.savedShowCode = code
                self.savedShowId = result.showId
                self.savedShow = result.showDt
                self.lookupByOrderResultViewModel.errorMessage = nil
                self.isUserLoggedIn = true
                self.showAlert = false
            }
            
            if let skinDict = result.skin {
                DRTDatabaseManager.shared.insertOrUpdateSkin(skinModel: skinDict, context: context)
            }
            
        } catch {
            await MainActor.run {
                self.isValidCode = false
                self.showAlert = true
                self.isUserLoggedIn = false
                if NetworkMonitor.shared.isNetworkAvailable() {
                    self.lookupByOrderResultViewModel.errorMessage = error.localizedDescription
                } else {
                    self.lookupByOrderResultViewModel.errorMessage = StringManager.shared.strings?.noInternet.description ?? StringConstants.Common.noInternetError
                }
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    func getShowCodeDataAsync(code: String) async throws -> DRTUser {
        return try await withCheckedThrowingContinuation { continuation in
            IQAPIClient.getShowCodeData(code: code) { result in
                switch result {
                case .success(let user):
                    self.drtUser = user
                    continuation.resume(returning: user)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
