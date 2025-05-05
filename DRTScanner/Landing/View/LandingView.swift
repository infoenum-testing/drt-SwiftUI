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
    @StateObject private var viewModel = LandingViewModel()
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
        ZStack {
            Image(StringConstants.DRTImages.backgound)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width)
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
            }
            else {
                
                VStack {
                    if viewModel.isValidCode && isUserLoggedIn {
                        HStack {
                            Text(savedShow)
                                .font(.verlagBoldAdaptive(size: 16))
                                .foregroundColor(.white)
                                .padding(.bottom)
                            
                            Spacer()
                            Text(StringConstants.LandingView.changeShow)
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
                            .frame(width: 300.adaptiveForIpad, height: 300.adaptiveForIpad)
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
                            Text(StringConstants.LandingView.scanMerchOrSeat)
                                .font(.verlagBlackAdaptive(size: 22))
                                .multilineTextAlignment(.center)
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
                            Text(StringConstants.LandingView.showCode)
                                .font(.verlagBoldAdaptive(size: 18))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.FFCE_62)
                                .foregroundColor(.white)
                        }
                        .opacity(animateButtons ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6).delay(0.9), value: animateButtons)
                    }
                    
                    // Copyright text
                    Text(StringConstants.LandingView.copyRight)
                        .font(.verlagBookAdaptive(size: 14))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                        .padding(.horizontal, 10)
                        .padding(.bottom)
                }
                // .padding()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        animateButtons = true
                    }
                }
                
                // Logout confirmation alert
                .customAlert(isPresented: $showLogoutAlert) {
                    VStack {
                        HStack {
                            Spacer()
                            Text(isOfflineMode ? StringConstants.Common.alert : StringConstants.Common.confirm)
                                .font(.verlagBoldAdaptive(size: 30))
                                .foregroundColor(.white)
                                .padding(.top, 20)
                                .padding(.leading, 30)
                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showLogoutAlert = false
                                }
                            }) {
                                Image(StringConstants.DRTImages.crossImage)
                                    .resizable()
                                    .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                                    .background(Color.clear)
                                    .contentShape(Rectangle())
                            }.padding(.trailing)
                        }
                        
                        Text(isOfflineMode ? StringConstants.LandingView.isOfflineAlertMessage :
                                StringConstants.LandingView.logoutConfirm)
                        .font(.verlagBookAdaptive(size: 18))
                        .foregroundStyle(Color.white)
                        .padding(.bottom)
                        .padding(.top)
                        
                        HStack {
                            if !isOfflineMode {
                                // Logout button
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
                                    Text(StringConstants.Common.logout)
                                        .font(.verlagBoldAdaptive(size: 22))
                                        .foregroundColor(.customGreen)
                                }
                                
                                Spacer()
                                
                                // Cancel button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showLogoutAlert = false
                                    }
                                }) {
                                    Text(StringConstants.Common.cancel)
                                        .font(.verlagBoldAdaptive(size: 22))
                                        .foregroundColor(.customGreen)
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding()
                    .background(Color.FFCE_62)
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
                                
                                Text(StringConstants.LandingView.invalidShowCode)
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
        }.frame(width: UIScreen.main.bounds.width)
            .ignoresSafeArea(.keyboard)
    }
}
