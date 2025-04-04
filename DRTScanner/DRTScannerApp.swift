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
    @State private var showSeatView: Bool = true
    @State private var isMerchandise: Bool = true
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            if isUserLoggedIn {
                LandingView().padding([.leading, .trailing], 20)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                LandingView().padding([.leading, .trailing], 20)
            }
        }
    }
}
