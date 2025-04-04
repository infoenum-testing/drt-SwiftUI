//
//  LandingView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 31/01/25.
//

//import SwiftUI
//import IQAPIClient
//
//struct LandingView: View {
//    @StateObject private var viewModel = LandingViewModel()
//    @State private var showSheet = false
//    @State private var showSeatView = false
//    @AppStorage("isMerchandise") private var isMerchandise: Bool = false
//    @AppStorage("showCode") private var showCode: String = ""
//    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
//    
//    var body: some View {
//        ZStack {
//            Image("background")
//                .resizable()
//                .scaledToFill()
//                .edgesIgnoringSafeArea(.all)
//                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//            
//            VStack {
//                Spacer()
//                Image("Logo")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 300, height: 300)
//                    .frame(alignment: .center)
//                
//                Spacer()
//                
//                if viewModel.isLoading {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: .customWhite))
//                        .padding(.bottom, 10)
//                }
//                
//                if !viewModel.isValidCode {
//                    Text(StringConstants.LandingView.invalidShowCode)
//                        .foregroundColor(.customWhite)
//                        .font(Font.custom("Verlag-Book", size: 15))
//                        .padding(.bottom, -5)
//                        .transition(.opacity)
//                }
//                
//                Button(action: {
//                    viewModel.isValidCode = true
//                    withAnimation(.easeInOut(duration: 0.3)) {
//                        showSheet = true
//                    }
//                }) {
//                    Text(StringConstants.LandingView.showCode)
//                        .font(Font.custom("Verlag-Bold", size: 18))
//                        .padding(.vertical, 20)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.FFCE_62)
//                        .foregroundColor(.customWhite)
//                }
//                .padding(.bottom, 10)
//                
//                Text(StringConstants.LandingView.copyRight)
//                    .font(Font.custom("Verlag-Book", size: 14))
//                    .foregroundColor(.customWhite)
//                    .multilineTextAlignment(.leading)
//                    .padding(.bottom, 30)
//                    .padding(.leading, 10)
//                    .padding(.trailing, 10)
//                    .frame(height: 65)
//            }.onAppear {
//                if isUserLoggedIn {
//                    showSeatView = true
//                }
//            }
//            .customAlert(isPresented: $viewModel.showAlert) {
//                VStack(alignment: .center) {
//                    HStack {
//                        Spacer()
//                        if viewModel.isValidCode {
//                            Spacer().padding(.leading)
//                        }
//                        Text(viewModel.isValidCode ? StringConstants.Common.alert : StringConstants.Common.error)
//                            .padding(.leading, 30)
//                            .font(Font.custom("Verlag-Bold", size: 30))
//                            .foregroundColor(.customWhite)
//                            .padding(.bottom, 10)
//                            .padding(.top, 20)
//                        if viewModel.isValidCode {
//                            Spacer()
//                                .padding(.trailing, 140)
//                                .frame(alignment: .leading)
//                        }
//                        Spacer()
//                        if !viewModel.isValidCode {
//                            Button(action: {
//                                withAnimation(.easeInOut(duration: 0.3)) {
//                                    viewModel.showAlert = false
//                                }
//                            }) {
//                                Image("Popup_cross_btn")
//                            }
//                        }
//                    }
//                    
//                    Text(viewModel.isValidCode ? StringConstants.LandingView.validShowCode : StringConstants.LandingView.invalidShowCode)
//                        .font(Font.custom("Verlag-Book", size: 18))
//                        .padding(.bottom)
//                        .foregroundColor(.customWhite)
//                    
//                    if viewModel.isValidCode {
//                        HStack {
//                            Text(StringConstants.LandingView.merchandise)
//                                .font(Font.custom("Verlag-Bold", size: 20))
//                                .foregroundColor(Color.customGreen)
//                                .padding(.leading, 30)
//                                .onTapGesture {
//                                    self.isUserLoggedIn = true
//                                    showSeatView = true
//                                    isMerchandise = true
//                                    viewModel.showAlert = false
//                                }
//                            Spacer()
//                            
//                            Text(StringConstants.LandingView.seat)
//                                .font(Font.custom("Verlag-Bold", size: 20))
//                                .foregroundColor(Color.customGreen)
//                                .padding(.trailing, 50)
//                                .onTapGesture {
//                                    self.isUserLoggedIn = true
//                                    showSeatView = true
//                                    isMerchandise = false
//                                    viewModel.showAlert = false
//                                }
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.top)
//                    }
//                }
//                .padding(.leading)
//                .padding(.trailing)
//                .padding(.bottom)
//                .background(Color.FFCE_62)
//            }
//            
//            .customAlert(isPresented: $showSheet) {
//                ShowCodeView(showSheet: $showSheet, onCodeEntered: { code in
//                    showCode = code
//                    Task {
//                        await viewModel.validateCode(code)
//                    }
//                })
//                .padding(.bottom)
//                .background(Color.clear)
//            }
//
//            if showSeatView {
//                SeatHomeView(showSeatView: $showSeatView)
//                    .zIndex(1)
//                    .transition(.move(edge: .top))
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .edgesIgnoringSafeArea(.all)
//                    .animation(.easeInOut(duration: 0.3), value: showSeatView)
//            }
//        }
//    }
//}

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
    @AppStorage("show") private var savedShow: String = ""

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
                .edgesIgnoringSafeArea(.all)

            VStack {
                if viewModel.isValidCode && isUserLoggedIn {
                    HStack {
                        Text(savedShow)
                            .font(Font.custom("Verlag-Black", size: 16))
                            .foregroundColor(.white)
                        
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
                            Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                .foregroundColor(.white)
                                .font(Font.custom("Verlag-Black", size: 30))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .transition(.opacity)
                }

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
                                .font(Font.custom("Verlag-Bold", size: 22))
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
                                .font(Font.custom("Verlag-Bold", size: 22))
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
                            .font(Font.custom("Verlag-Bold", size: 18))
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
            }
            .padding()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    animateButtons = true
                }
            }
           
            .customAlert(isPresented: $showLogoutAlert) {
                VStack {
                    HStack {
                        Spacer()
                        Text("Confirm")
                            .font(Font.custom("Verlag-Bold", size: 30))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                            .padding(.leading, 30)
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showLogoutAlert = false
                            }
                        }) {
                            Image("Popup_cross_btn").frame(width: 30, height: 30)
                        }.padding(.trailing)
                    }
                    
                    Text("Are you sure you want to logout?")
                        .font(Font.custom("Verlag-Bold", size: 22))
                        .foregroundStyle(Color.white)
                        .padding(.bottom)
                        .padding(.top)

                    HStack {
                        Button(action: {
                            isUserLoggedIn = false
                            isMerchandise = false
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showSeatView = false
                                showCode = ""
                                viewModel.isValidCode = false
                                showLogoutAlert = false
                            }
                        }) {
                            Text("Logout")
                                .font(Font.custom("Verlag-Bold", size: 22))
                                .foregroundColor(.customGreen)
                        }

                        Spacer()

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showLogoutAlert = false
                            }
                        }) {
                            Text("Cancel")
                                .font(Font.custom("Verlag-Bold", size: 22))
                                .foregroundColor(.customGreen)
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
                        await viewModel.validateCode(code)
                    }
                })
                .background(Color.clear)
                .padding(.trailing, 50)
            }
            
            .customAlert(isPresented: $viewModel.showAlert) {
                if !viewModel.isValidCode {
                    VStack(alignment: .center) {
                        HStack {
                            Spacer()
                            Text(StringConstants.Common.error)
                                .padding(.leading, 30)
                                .font(Font.custom("Verlag-Bold", size: 30))
                                .foregroundColor(.customWhite)
                                .padding(.bottom, 10)
                                .padding(.top, 20)
                            
                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.showAlert = false
                                }
                            }) {
                                Image("Popup_cross_btn").padding(.trailing, 20)
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

            if showSeatView {
                SeatHomeView(showSeatView: $showSeatView)
                    .zIndex(1)
                    .transition(.move(edge: .top))
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut(duration: 0.3), value: showSeatView)
                    .padding(.leading)
                    .padding(.trailing)
            }
        }
    }
}
