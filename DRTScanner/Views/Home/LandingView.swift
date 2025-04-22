//
//  LandingView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 31/01/25.
//

import SwiftUI
import IQAPIClient

struct LandingView: View {
    @StateObject private var viewModel = LandingViewModel()
    @State private var showSheet = false
    @State private var showSeatView = false
    @State private var showLogoutAlert = false
    @AppStorage("isMerchandise") private var isMerchandise: Bool = false
    @AppStorage("showCode") private var showCode: String = ""
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("show") private var savedShow: String = ""
    @Environment(\.managedObjectContext) private var context
    @State private var animateLogo = false
    @State private var animateButtons = false
    
    init() {
        if showCode.isEmpty {
            isUserLoggedIn = false
        }
    }
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width)
                .edgesIgnoringSafeArea(.all)
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
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
                                .font(Font.custom("Verlag-Black", size: 16))
                                .foregroundColor(.white)
                                .padding(.bottom)
                            
                            Spacer()
                            Text("Change Show")
                                .font(Font.custom("Verlag-Black", size: 16))
                                .foregroundColor(.white)
                                .padding(.bottom)
                            Button(action: {
                                withAnimation(.spring()) {
                                    showLogoutAlert = true
                                }
                            }) {
                                Image("logout")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .transition(.opacity)
                    }
                    
                    Spacer()
                    if viewModel.isLoading || !viewModel.isLoading {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .scaleEffect(animateLogo ? 1 : 0.8)
                            .opacity(animateLogo ? 1 : 0)
                            .animation(.easeOut(duration: 0.7), value: animateLogo)
                            .onAppear {
                                animateLogo = true
                            }
                    }
                    Spacer()
                    
                    if viewModel.isValidCode && isUserLoggedIn {
                        VStack {
                            Text("Do you want to scan merchandise or seats?")
                                .font(Font.custom("Verlag-Black", size: 22))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(.bottom, 20)
                                .opacity(animateButtons ? 1 : 0)
                                .animation(.easeInOut(duration: 0.5).delay(0.3), value: animateButtons)
                            
                            Button(action: {
                                //  isUserLoggedIn = true
                                isMerchandise = true
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSeatView = true
                                }
                            }) {
                                Text("MERCHANDISE")
                                    .font(Font.custom(StringConstants.DRTFont.verlagBold, size: 22))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.FFCE_62)
                                    .foregroundColor(.white)
                            }.padding(.horizontal)
                                .padding(.bottom, 10)
                                .opacity(animateButtons ? 1 : 0)
                                .animation(.easeInOut(duration: 0.6).delay(0.5), value: animateButtons)
                            
                            Button(action: {
                                //   isUserLoggedIn = true
                                isMerchandise = false
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSeatView = true
                                }
                            }) {
                                Text("SEAT")
                                    .font(Font.custom(StringConstants.DRTFont.verlagBold, size: 22))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.FFCE_62)
                                    .foregroundColor(.white)
                            }.padding(.horizontal)
                                .opacity(animateButtons ? 1 : 0)
                                .animation(.easeInOut(duration: 0.6).delay(0.7), value: animateButtons)
                        }
                    } else {
                        Button(action: {
                            withAnimation(.spring()) {
                                showSheet = true
                            }
                        }) {
                            Text("Enter Show Code")
                                .font(Font.custom(StringConstants.DRTFont.verlagBold, size: 18))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.FFCE_62)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .opacity(animateButtons ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6).delay(0.9), value: animateButtons)
                    }
                    
                    Text("Copyright(c) 2013-2025. DRT Performance Tix.\nAll Rights Reserved")
                        .font(Font.custom("Verlag-Book", size: 14))
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
                
                .customAlert(isPresented: $showLogoutAlert) {
                    VStack {
                        HStack {
                            Spacer()
                            Text(isOfflineMode ? "ALERT" : "Confirm")
                                .font(Font.custom(StringConstants.DRTFont.verlagBold, size: 30))
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
                                    .frame(width: 25, height: 25)
                                    .background(Color.clear)
                                    .contentShape(Rectangle())
                            }.padding(.trailing)
                        }
                        
                        Text(isOfflineMode ?
                             "You are currently scanning in OFFLINE MODE and therefore cannot log out. First, find connectivity and go back into online mode. Then you may log out" :
                                "Are you sure you want to log out?")
                        .font(Font.custom("Verlag-Book", size: 18))
                        .foregroundStyle(Color.white)
                        .padding(.bottom)
                        .padding(.top)
                        
                        HStack {
                            if !isOfflineMode {
                                Button(action: {
                                    isUserLoggedIn = false
                                    isMerchandise = false
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showSeatView = false
                                        showCode = ""
                                        viewModel.isValidCode = false
                                        showLogoutAlert = false
                                        DRTDatabaseManager.shared.deleteSkin()
                                    }
                                }) {
                                    Text("Logout")
                                        .font(Font.custom(StringConstants.DRTFont.verlagBold, size: 22))
                                        .foregroundColor(.customGreen)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showLogoutAlert = false
                                    }
                                }) {
                                    Text("Cancel")
                                        .font(Font.custom(StringConstants.DRTFont.verlagBold, size: 22))
                                        .foregroundColor(.customGreen)
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding()
                    .background(Color.FFCE_62)
                }
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
                
                .customAlert(isPresented: $viewModel.showAlert) {
                    if !viewModel.isValidCode {
                        VStack(alignment: .center) {
                            HStack {
                                Spacer()
                                Text(StringConstants.Common.error)
                                    .padding(.leading, 30)
                                    .font(Font.custom(StringConstants.DRTFont.verlagBold, size: 30))
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
                                        .frame(width: 25, height: 25)
                                        .background(Color.clear)
                                        .contentShape(Rectangle())
                                        .padding(.trailing, 20)
                                }
                            }
                            
                            Text(StringConstants.LandingView.invalidShowCode)
                                .font(Font.custom("Verlag-Book", size: 18))
                                .padding(.bottom)
                                .foregroundColor(.customWhite)
                        }
                        .padding()
                        .background(Color.FFCE_62)
                    }
                }
            }
            if showSeatView {
                SeatHomeView(showSeatView: $showSeatView)
                    .zIndex(1)
                    .transition(.move(edge: .top))
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut(duration: 0.3), value: showSeatView)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }.frame(width: UIScreen.main.bounds.width)
    }
}
