//
//  DRTScannerApp.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 05/02/25.
//

import SwiftUI

@main
struct DRTScannerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showSeatView: Bool = true
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            if showSeatView {
                //SeatHomeView(showSeatView: $showSeatView)
                ContentView(context: persistenceController.container.viewContext)
                                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                LandingView()
            }
        }
    }
}
