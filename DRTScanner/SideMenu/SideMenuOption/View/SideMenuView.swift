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
        let menuStrings = stringManager.strings?.menu
        let menuStringsConstant =  StringConstants.SideMenuView.self
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
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    isPresented = false
                                }
                            }) {
                                Image(StringConstants.DRTImages.crossImage)
                                    .resizable()
                                    .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                                    .background(Color.clear)
                                    .contentShape(Rectangle())
                                    .padding()
                            }
                            .padding(.top, 38)
                        }
                
                    
                        // Merchandise/Ticket switch option
                        if isMerchandise {
                            SideMenuOption(imageName: "scan_seat", title: menuStrings?.scanTickets ?? menuStringsConstant.scanTicket) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isSwitchingToMerchandise = !isMerchandise
                                    showConfirmationAlert = true
                                }
                            }
                        } else {
                            SideMenuOption(imageName: "scan_seat", title: menuStrings?.scanMerch ?? menuStringsConstant.scanMerchandise) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isSwitchingToMerchandise = !isMerchandise
                                    showConfirmationAlert = true
                                }
                            }
                        }
                        
                        // Settings option
                        SideMenuOption(imageName: "setting", title: menuStrings?.settings ?? menuStringsConstant.setting) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSettingsView = true
                            }
                        }
                        
                        // Scanning Stats option (only if not in merchandise mode)
                        if !isMerchandise {
                            SideMenuOption(imageName: "statics", title: menuStrings?.scanningStats ?? menuStringsConstant.scaningStats) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showScanningStatsView = true
                                }
                            }
                        }
                        // Go Online/Offline option
                        if isOfflineMode {
                            SideMenuOption(imageName: "online", title: menuStrings?.goOnline ?? menuStringsConstant.goOnline) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showGoOnlineView = true
                                }
                            }
                            
                        } else {
                            SideMenuOption(imageName: "offline", title: menuStrings?.goOffline ?? menuStringsConstant.goOffline) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showGoOfflineView = true
                                }
                            }
                        }
                        
                        // Logout option
                        SideMenuOption(imageName: "logout", title: menuStrings?.logOut ?? menuStringsConstant.logout) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAlert = true
                            }
                        }
                        // About option
                        SideMenuOption(imageName: "information", title: menuStrings?.about ?? menuStringsConstant.about) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showAboutView = true
                            }
                        }
                        // DRT Website option
                        SideMenuOption(imageName: "settingweb", title: menuStrings?.website ?? menuStringsConstant.drtWebsite) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showWebsiteAlert = true
                            }
                        }
                        // Alert for opening website
                        .alert(isPresented: $showWebsiteAlert) {
                            Alert(
                                title: Text(stringManager.strings?.dialogOpenBrowser.description ?? menuStringsConstant.openDrtWebsiteMessage),
                                message: Text(""),
                                primaryButton: .default(Text( stringManager.strings?.dialogOpenBrowser.continueField ?? "OPEN")) {
                                    openDRTWebsite()
                                },
                                secondaryButton: .cancel(Text(stringManager.strings?.dialogOpenBrowser.cancel ?? "CANCEL"))
                            )
                        }
                        
                    }
                    .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width * 0.8 : min(geometry.size.width * 0.8, 400))
                    .background(Color.neutralBg)
                    Spacer()
                }.onAppear {
                    // Set initial merchandise switch state
                    isSwitchingToMerchandise = !isMerchandise
                    print(isSwitchingToMerchandise ?? false,"")
                }
            }.onTapGesture {
                isPresented = false
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
            ZStack(alignment: .top) {
                AppBackGroundView(width:UIScreen.main.bounds.width,height: UIScreen.main.bounds.height * 0.4,shadow:true)
                VStack(alignment: .center) {
                    Spacer()
                    Text("\(isSwitchingToMerchandise ?? !isMerchandise ? stringManager.strings?.switchMode.merch ?? menuStringsConstant.merchandise : stringManager.strings?.switchMode.tickets ?? menuStringsConstant.ticket)")
                        .font(.verlagBoldAdaptive(size: 26))
                        .foregroundColor(Color.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    
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
                                Text(stringManager.strings?.switchMode.yes ?? "YES")
                                    .font(.verlagBoldAdaptive(size: 30))
                                    .foregroundColor(Color.primaryText)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            }
                            .background(Color.secondaryBg)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 5)
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
                                Text(stringManager.strings?.switchMode.no ?? "NO")
                                    .font(.verlagBoldAdaptive(size: 30))
                                    .foregroundColor(Color.primaryText)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            }
                            Spacer()
                        }.background(Color.clear)
                            .padding(.horizontal)
                        
                    }.onChange(of: isSwitchingToMerchandise ?? false) { newValue in
                        isMerchandise = newValue
                    }
                    Spacer()
                }
            }
            .frame(width:UIScreen.main.bounds.width,height: UIScreen.main.bounds.height * 0.4)
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
