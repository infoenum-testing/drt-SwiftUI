//
//  LandingView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 31/01/25.
//

import SwiftUI
import IQAPIClient

// Main landing view for the app
struct LandingView: View {
    @StateObject private var viewModel = LandingViewModel(lookupByOrderResultViewModel: LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext))
    // Controls the display of the show code sheet
    @State private var showSheet = false
    // Controls the display of the seat view
    @State private var showSeatView = false
    // Controls the display of the logout alert
    @State private var showLogoutAlert = false
    @AppStorage("isMerchandise") private var isMerchandise: Bool = false
    @AppStorage("showCode") private var showCode: String = ""
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("show") private var savedShow: String = ""
    @AppStorage("deviceScanCount") private var deviceScanCount: Int = 0
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var stringManager: StringManager
    @Environment(\.sizeData) var sizeData
    // Animation state variables
    @State private var animateLogo = false
    @State private var animateButtons = false
    
    // Initializer to check if user is logged in based on showCode
    init() {
        if showCode.isEmpty {
            isUserLoggedIn = false
        }
    }
    
    var body: some View {
//        ScrollView {
            ZStack {
                Image(StringConstants.DRTImages.backgound)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .edgesIgnoringSafeArea(.all)
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        Image(StringConstants.DRTImages.logo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300.adaptiveForIpad, height: 300.adaptiveForIpad)
                            .scaleEffect(animateLogo ? 1 : 0.8)
                            .opacity(animateLogo ? 1 : 0)
                            .animation(.easeOut(duration: 0.7), value: animateLogo)
                            .onAppear {
                                animateLogo = true
                            }
                        Spacer()
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .foregroundColor(.white)
                            .scaleEffect(1.5)
                            .padding(.bottom)
                    }
                } else {
                    
                    VStack {
                        if viewModel.isValidCode && isUserLoggedIn {
                            HStack {
                                Text(savedShow)
                                    .font(.verlagBoldAdaptive(size: 16))
                                    .foregroundColor(.white)
                                    .padding(.bottom)
                                
                                Spacer()
                                Text(stringManager.strings?.menu.change ?? StringConstants.LandingView.changeShow)
                                    .font(.verlagBoldAdaptive(size: 16))
                                    .foregroundColor(.white)
                                    .padding(.bottom)
                                Button(action: {
                                    withAnimation(.spring()) {
                                        showLogoutAlert = true
                                    }
                                }) {
                                    Image(StringConstants.DRTImages.logout)
                                        .resizable()
                                        .frame(width: 40.adaptiveForIpad, height: 40.adaptiveForIpad)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .transition(.opacity)
                        }
                        
                        Spacer()
                        // Always show logo (with animation)
                        if viewModel.isLoading || !viewModel.isLoading {
                            Image(StringConstants.DRTImages.logo)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300.adaptiveForIpad, height: sizeData.isPortrait ? 300.adaptiveForIpad : 100.adaptiveForIpad)
                                .scaleEffect(animateLogo ? 1 : 0.8)
                                .opacity(animateLogo ? 1 : 0)
                                .animation(.easeOut(duration: 0.7), value: animateLogo)
                                .onAppear {
                                    animateLogo = true
                                }
                        }
                        Spacer()
                        
                        // Show scan options if code is valid and user is logged in
                        if viewModel.isValidCode && isUserLoggedIn {
                            VStack {
                                Text(stringManager.strings?.switchMode.question ?? StringConstants.LandingView.scanMerchOrSeat)
                                    .font(.verlagBoldAdaptive(size: 28))
                                    .multilineTextAlignment(.center)
                                //                                .minimumScaleFactor(0.5)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 20)
                                    .opacity(animateButtons ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.5).delay(0.3), value: animateButtons)
                                
                                // Merchandise scan button
                                Button(action: {
                                    //  isUserLoggedIn = true
                                    isMerchandise = true
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showSeatView = true
                                    }
                                }) {
                                    Text(StringConstants.LandingView.merchandise)
                                        .font(.verlagBoldAdaptive(size: 22))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.FFCE_62)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }.padding(.horizontal)
                                    .padding(.bottom, 10)
                                    .opacity(animateButtons ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.6).delay(0.5), value: animateButtons)
                                
                                // Seat scan button
                                Button(action: {
                                    //   isUserLoggedIn = true
                                    isMerchandise = false
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showSeatView = true
                                    }
                                }) {
                                    Text(StringConstants.LandingView.seat)
                                        .font(.verlagBoldAdaptive(size: 22))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.FFCE_62)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }.padding(.horizontal)
                                    .opacity(animateButtons ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.6).delay(0.7), value: animateButtons)
                            }
                        } else {
                            // Show code entry button if not logged in
                            Button(action: {
                                withAnimation(.spring()) {
                                    showSheet = true
                                }
                            }) {
                                Text(stringManager.strings?.login.enterShowCode ?? StringConstants.LandingView.showCode)
                                    .font(.verlagBoldAdaptive(size: 22))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.FFCE_62)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }.padding(.horizontal)
                            
                                .opacity(animateButtons ? 1 : 0)
                                .animation(.easeInOut(duration: 0.6).delay(0.9), value: animateButtons)
                        }
                        
                        // Copyright text
                        Text(stringManager.strings?.copyright.replacingOccurrences(of: ". All", with: ".\n All") ?? StringConstants.LandingView.copyRight)
                            .font(.verlagBookAdaptive(size: 14))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.horizontal, 10)
                            .padding(.bottom)
                    }
                    .padding(.vertical)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            animateButtons = true
                        }
                    }
                    
                    // Logout confirmation alert
                    .customAlert(isPresented: $showLogoutAlert) {
                        VStack {
                            Text(isOfflineMode ? stringManager.strings?.dialogLogout.whenOfflineDescription ?? StringConstants.LandingView.isOfflineAlertMessage : stringManager.strings?.dialogLogout.areYouSure ??
                                 StringConstants.LandingView.logoutConfirm)
                            .font(isOfflineMode ? .verlagBookAdaptive(size: 18) : .verlagBoldAdaptive(size: 26))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                            .lineLimit(isOfflineMode ? 10 : 1)
                            .padding(.top, 20)
                            .padding(.bottom)
                            
                            VStack {
                                if !isOfflineMode {
                                    // Logout button
                                    HStack {
                                        Button(action: {
                                            isUserLoggedIn = false
                                            isMerchandise = false
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showSeatView = false
                                                showCode = ""
                                                viewModel.isValidCode = false
                                                showLogoutAlert = false
                                                deviceScanCount = 0
                                                DRTDatabaseManager.shared.deleteSkin()
                                            }
                                        }) {
                                            Text(stringManager.strings?.dialogLogout.continueField ?? StringConstants.Common.logout)
                                                .font(.verlagBoldAdaptive(size: 30))
                                                .foregroundColor(Color.customWhite)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.FFCE_62)
                                                .cornerRadius(12)
                                        }
                                    }
                                    //                                Spacer()
                                    HStack {
                                        // Cancel button
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showLogoutAlert = false
                                            }
                                        }) {
                                            Text(stringManager.strings?.dialogLogout.cancel ?? StringConstants.Common.cancel)
                                                .font(.verlagBoldAdaptive(size: 30))
                                                .foregroundColor(Color.customWhite)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background {
                            Image(StringConstants.DRTImages.backgound)
                                .resizable()
                                .scaledToFill()
                                .frame(height: UIScreen.main.bounds.height * 0.35)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .edgesIgnoringSafeArea(.top)
                        }
                    }
                    // Show code entry sheet
                    .customAlert(isPresented: $showSheet) {
                        ShowCodeView(showSheet: $showSheet, onCodeEntered: { code in
                            showCode = code
                            Task {
                                await viewModel.validateCode(code, context: context)
                            }
                        })
                        .background(Color.clear)
                        //  .padding([.trailing, .leading], 50)
                    }.edgesIgnoringSafeArea(.bottom)
                    
                    // Invalid code alert
                        .customAlert(isPresented: $viewModel.showAlert) {
                            if !viewModel.isValidCode {
                                VStack(alignment: .center) {
                                    HStack {
                                        Spacer()
                                        Text(StringConstants.Common.error)
                                            .padding(.leading, 30)
                                            .font(.verlagBoldAdaptive(size: 30))
                                            .foregroundColor(.customWhite)
                                            .padding(.bottom, 10)
                                            .padding(.top, 20)
                                        
                                        Spacer()
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                viewModel.showAlert = false
                                            }
                                        }) {
                                            Image(StringConstants.DRTImages.crossImage)
                                                .resizable()
                                                .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                                                .background(Color.clear)
                                                .contentShape(Rectangle())
                                                .padding(.trailing, 20)
                                        }
                                    }
                                    
                                    Text(viewModel.lookupByOrderResultViewModel.errorMessage ?? StringConstants.LandingView.invalidShowCode)
                                        .font(.verlagBookAdaptive(size: 18))
                                        .padding(.bottom)
                                        .foregroundColor(.customWhite)
                                }
                                .padding()
                                .background(Color.FFCE_62)
                            }
                        }
                }
                // Show seat view overlay if selected
                if showSeatView {
                    SeatHomeView(showSeatView: $showSeatView)
                        .zIndex(1)
                        .transition(.move(edge: .top))
                        .edgesIgnoringSafeArea(.all)
                        .animation(.easeInOut(duration: 0.3), value: showSeatView)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                }
            }.ignoresSafeArea(.keyboard)
                .onChange(of: sizeData.isPortrait) { newValue in
                    //                viewModel.isLoading = true
                    //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    //                    viewModel.isLoading = false
                    //                }
                }
//        }.scrollDisabled(true)
//            .ignoresSafeArea(edges: .top)
    }
}
