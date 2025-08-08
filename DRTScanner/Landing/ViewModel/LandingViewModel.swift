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
                DRTDatabaseManager.shared.insertOrUpdateSkin(skinModel: skin, context: context)

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
                UserDefaults.standard.set(Date(), forKey: "lastSkinUpdate")
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
    
    func getShowDetailsIfNeeded() {
        guard !lastSkinUpdate() else { return }

        Task {
            guard let code = UserDefaults.standard.string(forKey: "showCode") else { return }
            do {
                let result = try await getShowCodeDataAsync(code: code)
                print("Received result: \(result)")
                if let skin = result.skin {
                    UserDefaults.standard.set(Date(), forKey: "lastSkinUpdate")
                    ColorManager.shared.updateSkin(to: skin)
                    let context = PersistenceController.shared.container.viewContext
                    DRTDatabaseManager.shared.insertOrUpdateSkin(skinModel: skin, context: context)
                }
            } catch {
                print("❌ Failed to fetch show code data: \(error)")
                // You can also show an alert, log error, etc.
            }
        }
    }
    
    func getShowCodeDataAsync(code: String) async throws -> DRTUser {
        return try await withCheckedThrowingContinuation { continuation in
            IQAPIClient.getShowCodeData(code: code) { result in
                switch result {
                case .success(let user):
                    self.drtUser = user
                    UserDefaults.standard.set(Date(), forKey: "lastSkinUpdate")
                    continuation.resume(returning: user)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func lastSkinUpdate() -> Bool {
        let now = Date()
        if let lastCall = UserDefaults.standard.object(forKey: "lastSkinUpdate") as? Date {
            let hoursSinceLastCall = now.timeIntervalSince(lastCall) / 3600
            return hoursSinceLastCall >= 24
        }
        return true // No previous call, so allow
    }
}
