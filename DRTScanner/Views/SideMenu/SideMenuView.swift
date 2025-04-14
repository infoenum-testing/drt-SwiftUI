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
    @State var isSwitchingToMerchandise: Bool?
    @State private var showConfirmationAlert = false
    @State private var showWebsiteAlert = false
    
    
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("isMerchandise") private var isMerchandise: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    VStack(spacing: 5) {
                        HStack {
                            Spacer()
                            Button(action: { isPresented = false }) {
                                Image("Popup_cross_btn")
                                    .padding()
                            }
                            .padding(.top, 30)
                        }
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
                        if !isMerchandise {
                            SideMenuOption(title: "SCANNING STATS") {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showScanningStatsView = true
                                }
                                isPresented = true
                            }
                        }
                        
                        SideMenuOption(title: "SETTINGS") {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSettingsView = true
                            }
                        }
                        
                        if isMerchandise {
                            SideMenuOption(title: "SCAN TICKETS") {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isSwitchingToMerchandise = !isMerchandise
                                    showConfirmationAlert = true
                                }
                            }
                        } else {
                            SideMenuOption(title: "SCAN MERCHANDISE") {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isSwitchingToMerchandise = !isMerchandise
                                    showConfirmationAlert = true
                                }
                            }
                        }
                        
                        SideMenuOption(title: "LOG OUT") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAlert = true
                            }
                        }
                        
                        SideMenuOption(title: "ABOUT") {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showAboutView = true
                            }
                            isPresented = false
                        }
                        
                        SideMenuOption(title: "DRT WEBSITE") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showWebsiteAlert = true
                            }
                        }
                        .alert(isPresented: $showWebsiteAlert) {
                            Alert(
                                title: Text("Open DRT Website?"),
                                message: Text("Do you want to visit the DRT website?"),
                                primaryButton: .default(Text("Yes")) {
                                    openDRTWebsite()
                                },
                                secondaryButton: .cancel(Text("No"))
                            )
                        }
                        
                    }
                    .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? min(geometry.size.width * 0.5, 450) : min(geometry.size.width * 0.8, 400))
                    .background(Color.tealLight)
                    Spacer()
                }.onAppear {
                    isSwitchingToMerchandise = !isMerchandise
                    print(isSwitchingToMerchandise ?? false,"")
                }
            }
        }.sideMenuViewModify(isPresented: $showSettingsView) {
            withAnimation(.easeInOut(duration: 0.3)) {
                SettingsView(isPresented: $showSettingsView).padding(.top, 30)
            }
        }
        .customAlert(isPresented: $showGoOnlineView) {
            GoOnlineView(isPresented: $showGoOnlineView)
        }
        .customAlert(isPresented: $showConfirmationAlert) {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    Color.black.opacity(0.0)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showConfirmationAlert = false
                            }
                        }
                    
                    VStack(alignment: .center) {
                        
                        Text("Switch to scanning \(isSwitchingToMerchandise ?? !isMerchandise ? "merchandise?" : "tickets?")")
                            .font(Font.custom("Verlag-Bold", size: 26))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        HStack {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isMerchandise = isSwitchingToMerchandise ?? false
                                    showConfirmationAlert = false
                                }
                            }) {
                                Text("Yes")
                                    .font(Font.custom("Verlag-Bold", size: 24))
                                    .foregroundColor(Color.customGreen)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            }
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showConfirmationAlert = false
                                }
                            }) {
                                Text("No")
                                    .font(Font.custom("Verlag-Bold", size: 24))
                                    .foregroundColor(Color.customGreen)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            }
                        }.onChange(of: isSwitchingToMerchandise ?? false) { newValue in
                            isMerchandise = newValue
                        }
                    }
                    .padding(.top,30)
                    .background(Color.FFCE_62)
                    .frame(width: geometry.size.width * 1)
                    .position(x: geometry.size.width / 2, y: geometry.safeAreaInsets.top + 100)
                }.onChange(of: isSwitchingToMerchandise) { _ in
                    print(isSwitchingToMerchandise ?? false,"")
                }
                
            }
            .padding(.top, 0)
            .edgesIgnoringSafeArea(.all)
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
