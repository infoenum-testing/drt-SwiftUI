//
//  DRTScannerApp.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 05/02/25.
//

import SwiftUI

@main
struct DRTScannerApp: App {
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    
    @StateObject private var inactivityManager = InactivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isUserLoggedIn {
                    LandingView()
                        .padding([.leading, .trailing], 20)
                        .environmentObject(inactivityManager)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                } else {
                    LandingView()
                        .padding([.leading, .trailing], 20)
                        .environmentObject(inactivityManager)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                }
            } .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .ignoresSafeArea(.keyboard, edges: .bottom)
            .detectGlobalTaps(disabled: false)
            .onAppear {
                InactivityManager.shared.start()
            }
        }
    }
}
