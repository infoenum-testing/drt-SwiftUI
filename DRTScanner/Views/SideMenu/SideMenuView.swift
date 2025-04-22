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
                                Image(StringConstants.DRTImages.crossImage)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .background(Color.clear)
                                    .contentShape(Rectangle())
                                    .padding()
                            }
                            .padding(.top, 30)
                        }
                        if isOfflineMode {
                            SideMenuOption(title: StringConstants.SideMenuView.goOnline) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showGoOnlineView = true
                                }
                            }
                            
                        } else {
                            SideMenuOption(title: StringConstants.SideMenuView.goOffline) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showGoOfflineView = true
                                }
                                // isPresented = false
                            }
                        }
                        if !isMerchandise {
                            SideMenuOption(title: StringConstants.SideMenuView.scaningStats) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showScanningStatsView = true
                                }
                                // isPresented = true
                            }
                        }
                        
                        SideMenuOption(title: StringConstants.SideMenuView.setting) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSettingsView = true
                            }
                        }
                        
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
                        
                        SideMenuOption(title: StringConstants.SideMenuView.logout) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAlert = true
                            }
                        }
                        
                        SideMenuOption(title: StringConstants.SideMenuView.about) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showAboutView = true
                            }
                            //   isPresented = false
                        }
                        
                        SideMenuOption(title: StringConstants.SideMenuView.drtWebsite) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showWebsiteAlert = true
                            }
                        }
                        .alert(isPresented: $showWebsiteAlert) {
                            Alert(
                                title: Text(StringConstants.SideMenuView.openDrtWebsiteTitle),
                                message: Text(StringConstants.SideMenuView.openDrtWebsiteMessage),
                                primaryButton: .default(Text(StringConstants.Common.yes)) {
                                    openDRTWebsite()
                                },
                                secondaryButton: .cancel(Text(StringConstants.Common.no))
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
                        
                        Text("Switch to scanning \(isSwitchingToMerchandise ?? !isMerchandise ? StringConstants.SideMenuView.merchandise : StringConstants.SideMenuView.ticket)")
                            .font(Font.custom(StringConstants.DRTFont.verlagBold, size: 26))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showConfirmationAlert = false
                                    }
                                }) {
                                    Text(StringConstants.Common.no)
                                        .font(Font.custom(StringConstants.DRTFont.verlagBold, size: 30))
                                        .foregroundColor(Color.customWhite)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                }
                                Spacer()
                            }.background(Color.FFCE_62)
                                .padding(.horizontal, 30)
                                .padding(.top)
                            
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        isMerchandise = isSwitchingToMerchandise ?? false
                                        showConfirmationAlert = false
                                    }
                                }) {
                                    Text(StringConstants.Common.yes)
                                        .font(Font.custom(StringConstants.DRTFont.verlagBold, size: 30))
                                        .foregroundColor(Color.customWhite)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                }
                                Spacer()
                            }.background(Color.FFCE_62)
                                .padding(.horizontal, 30)
                            
                        }.onChange(of: isSwitchingToMerchandise ?? false) { newValue in
                            isMerchandise = newValue
                        }
                    }
                    .padding(.top, 100)
                    .padding(.bottom)
                    .background {
                        Image(StringConstants.DRTImages.backgound)
                            .resizable()
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
    
    private func toggleOfflineMode() {
        isOfflineMode.toggle()
    }
    
    private func openDRTWebsite() {
        if let url = URL(string: StringConstants.SideMenuView.drtWebsiteURL) {
            UIApplication.shared.open(url)
        }
    }
}
