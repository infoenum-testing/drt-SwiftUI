//
//  DRTScannerApp.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 05/02/25.
//

import SwiftUI
import IQAPIClient
import SDWebImage
import SDWebImageSVGCoder

@main
struct DRTScannerApp: App {
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    @StateObject var stringManager = StringManager.shared
    @StateObject var network = NetworkMonitor.shared
    @StateObject private var inactivityManager = InactivityManager.shared
    @State private var sizeData: SizeData = .empty
    
    init() {
        let svgCoder = SDImageSVGCoder.shared
        SDImageCodersManager.shared.addCoder(svgCoder)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                LandingView()
                    .padding([.leading, .trailing], 20)
                    .environmentObject(inactivityManager)
                    .environmentObject(stringManager)
                    .environmentObject(network)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .environment(\.sizeData, sizeData)
                    .readSizeData($sizeData)
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)

            .ignoresSafeArea(.keyboard, edges: .bottom)
            .detectGlobalTaps(disabled: false)
            .onAppear {
                InactivityManager.shared.start()
                stringManager.loadStrings()
            }
        }
    }
}
