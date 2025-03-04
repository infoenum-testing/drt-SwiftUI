//
//  SideMenuView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 10/02/25.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isPresented: Bool
    @Binding var showGoOfflineView: Bool
    @Binding var showScanningStatsView: Bool
    @Binding var showAboutView: Bool
    @Binding var showAlert: Bool
    @State private var showGoOnlineView = false
    @State private var showSettingsView = false
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            VStack(alignment: .trailing) {
                Button(action: { isPresented = false }) {
                    Image("Popup_cross_btn")
                        .padding()
                }
                .padding(.top, 50)
                
                VStack(alignment: .leading, spacing: 20) {
                    if isOfflineMode {
                        SideMenuOption(title: "GO ONLINE") {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showGoOnlineView = true
                            }
                        }
                    } else {
                        SideMenuOption(title: "GO OFFLINE") {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showGoOfflineView = true
                            }
                            isPresented = false
                        }
                    }
                    SideMenuOption(title: "SCANNING STATS") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showScanningStatsView = true
                        }
                        isPresented = true
                    }
                    SideMenuOption(title: "ABOUT") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showAboutView = true
                        }
                        isPresented = false
                    }
                    SideMenuOption(title: "STOP SCANNING") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAlert = true
                        }
                    }
                    SideMenuOption(title: "DRT WEBSITE") {
                        openDRTWebsite()
                    }
                    SideMenuOption(title: "SETTINGS") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSettingsView = true
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .frame(width: 250)
            .background(Color.sideMenu)
            .edgesIgnoringSafeArea(.all)
        } .customAlert(isPresented: $showSettingsView) {
            withAnimation(.easeInOut(duration: 0.3)) {
                SettingsView(isPresented: $showSettingsView)
            }
        }
        .customAlert(isPresented: $showGoOnlineView) {
            GoOnlineView(isPresented: $showGoOnlineView)
        }
    }

    private func toggleOfflineMode() {
        isOfflineMode.toggle()
    }

    private func openDRTWebsite() {
        if let url = URL(string: "https://www.drtwebsite.com") {
            UIApplication.shared.open(url)
        }
    }
}

struct SideMenuOption: View {
    var title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(Font.custom("Verlag-Bold", size: 15))
                .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .onTapGesture {
            action?()
        }
    }
}
