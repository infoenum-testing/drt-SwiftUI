//
//  SideMenuView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 10/02/25.
//

import SwiftUI

// SideMenuView displays the side menu with navigation options and handles related actions
struct SideMenuView: View {
    // Bindings to control presentation and navigation
    @Binding var isPresented: Bool
    @Binding var showGoOfflineView: Bool
    @Binding var showScanningStatsView: Bool
    @Binding var showAboutView: Bool
    @Binding var showAlert: Bool
    // Local state variables for view presentation
    @State private var showGoOnlineView = false
    @State private var showSettingsView = false
    @State var isSwitchingToMerchandise: Bool?
    @State private var showConfirmationAlert = false
    @State private var showWebsiteAlert = false
    
    // AppStorage properties for persistent mode flags
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("isMerchandise") private var isMerchandise: Bool = false
    @EnvironmentObject var stringManager: StringManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                // Dimmed background
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    VStack(spacing: 5) {
                        // Close button
                        HStack {
                            Spacer()
                            Button(action: { isPresented = false }) {
                                Image(StringConstants.DRTImages.crossImage)
                                    .resizable()
                                    .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                                    .background(Color.clear)
                                    .contentShape(Rectangle())
                                    .padding()
                            }
                            .padding(.top, 30)
                        }
                        // Go Online/Offline option
                        if isOfflineMode {
                            SideMenuOption(title: stringManager.strings?.menu.goOnline ?? StringConstants.SideMenuView.goOnline) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showGoOnlineView = true
                                }
                            }
                            
                        } else {
                            SideMenuOption(title: stringManager.strings?.menu.goOffline ?? StringConstants.SideMenuView.goOffline) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showGoOfflineView = true
                                }
                                // isPresented = false
                            }
                        }
                        // Scanning Stats option (only if not in merchandise mode)
                        if !isMerchandise {
                            SideMenuOption(title: StringConstants.SideMenuView.scaningStats) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showScanningStatsView = true
                                }
                                // isPresented = true
                            }
                        }
                        // Settings option
                        SideMenuOption(title: StringConstants.SideMenuView.setting) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSettingsView = true
                            }
                        }
                        // Merchandise/Ticket switch option
                        if isMerchandise {
                            SideMenuOption(title: StringConstants.SideMenuView.scanTicket) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isSwitchingToMerchandise = !isMerchandise
                                    showConfirmationAlert = true
                                }
                            }
                        } else {
                            SideMenuOption(title: StringConstants.SideMenuView.scanMerchandise) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isSwitchingToMerchandise = !isMerchandise
                                    showConfirmationAlert = true
                                }
                            }
                        }
                        // Logout option
                        SideMenuOption(title: StringConstants.SideMenuView.logout) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAlert = true
                            }
                        }
                        // About option
                        SideMenuOption(title: stringManager.strings?.menu.about ?? StringConstants.SideMenuView.about) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showAboutView = true
                            }
                            //   isPresented = false
                        }
                        // DRT Website option
                        SideMenuOption(title: stringManager.strings?.menu.website ?? StringConstants.SideMenuView.drtWebsite) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showWebsiteAlert = true
                            }
                        }
                        // Alert for opening website
                        .alert(isPresented: $showWebsiteAlert) {
                            Alert(
                                title: Text(stringManager.strings?.dialogOpenBrowser.description ?? StringConstants.SideMenuView.openDrtWebsiteMessage),
                                message: Text(""),
                                primaryButton: .default(Text( "OPEN")) {
                                    openDRTWebsite()
                                },
                                secondaryButton: .cancel(Text("CANCEL"))
                            )
                        }
                        
                    }
                    .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width * 0.8 : min(geometry.size.width * 0.8, 400))
                    .background(Color.tealLight)
                    Spacer()
                }.onAppear {
                    // Set initial merchandise switch state
                    isSwitchingToMerchandise = !isMerchandise
                    print(isSwitchingToMerchandise ?? false,"")
                }
            }
        }.sideMenuViewModify(isPresented: $showSettingsView) {
            // Settings view presentation
            withAnimation(.easeInOut(duration: 0.3)) {
                SettingsView(isPresented: $showSettingsView).padding(.top, 30)
            }
        }
        // Go Online view presentation
        .customAlert(isPresented: $showGoOnlineView) {
            GoOnlineView(isPresented: $showGoOnlineView)
        }
        // Confirmation alert for switching merchandise/ticket mode
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
                        // Confirmation message
                        Text("\(isSwitchingToMerchandise ?? !isMerchandise ? stringManager.strings?.switchMode.merch ?? StringConstants.SideMenuView.merchandise : stringManager.strings?.switchMode.tickets ?? StringConstants.SideMenuView.ticket)")
                            .font(.verlagBoldAdaptive(size: 26))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                        
                        VStack {
                            // NO button
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        isMerchandise = isSwitchingToMerchandise ?? false
                                        showConfirmationAlert = false
                                        isPresented = false
                                    }
                                }) {
                                    Text("YES")
                                        .font(.verlagBoldAdaptive(size: 30))
                                        .foregroundColor(Color.customWhite)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                }
                                .background(Color.FFCE_62)
                                   .cornerRadius(12)
                                Spacer()
                            }
                            
                                .padding(.horizontal)
                                .padding(.top)
                            
                            // YES button
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showConfirmationAlert = false
                                    }
                                }) {
                                    Text("NO")
                                        .font(.verlagBoldAdaptive(size: 30))
                                        .foregroundColor(Color.customWhite)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                }
                                Spacer()
                            }.background(Color.clear)
                                .padding(.horizontal)
                            
                        }.onChange(of: isSwitchingToMerchandise ?? false) { newValue in
                            isMerchandise = newValue
                        }
                    }
                    .padding(.top, 70)
                    .padding(.bottom)
                    .background {
                        Image(StringConstants.DRTImages.backgound)
                            .resizable()
                            .scaledToFill()
                            .frame(height: UIScreen.main.bounds.height * 0.38)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .edgesIgnoringSafeArea(.top)
                    }
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
    
    // Toggles the offline mode flag
    private func toggleOfflineMode() {
        isOfflineMode.toggle()
    }
    
    // Opens the DRT website in the default browser
    private func openDRTWebsite() {
        if let url = URL(string: stringManager.strings?.serviceHref ?? StringConstants.SideMenuView.drtWebsiteURL) {
            UIApplication.shared.open(url)
        }
    }
}
