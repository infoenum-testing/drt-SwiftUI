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
    @AppStorage("isMerchandise") private var isMerchandise: Bool = false
    @AppStorage("showCode") private var showCode: String = ""
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            VStack {
                Spacer()
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .frame(alignment: .center)
                
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .customWhite))
                        .padding(.bottom, 10)
                }
                
                if !viewModel.isValidCode {
                    Text(StringConstants.LandingView.invalidShowCode)
                        .foregroundColor(.customWhite)
                        .font(Font.custom("Verlag-Book", size: 15))
                        .padding(.bottom, -5)
                        .transition(.opacity)
                }
                
                Button(action: {
                    viewModel.isValidCode = true
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSheet = true
                    }
                }) {
                    Text(StringConstants.LandingView.showCode)
                        .font(Font.custom("Verlag-Bold", size: 18))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color.FFCE_62)
                        .foregroundColor(.customWhite)
                }
                .padding(.bottom, 10)
                
                Text(StringConstants.LandingView.copyRight)
                    .font(Font.custom("Verlag-Book", size: 14))
                    .foregroundColor(.customWhite)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 30)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .frame(height: 65)
            }.onAppear {
                if isUserLoggedIn {
                    showSeatView = true
                }
            }
            .customAlert(isPresented: $viewModel.showAlert) {
                VStack(alignment: .center) {
                    HStack {
                        Spacer()
                        if viewModel.isValidCode {
                            Spacer().padding(.leading)
                        }
                        Text(viewModel.isValidCode ? StringConstants.Common.alert : StringConstants.Common.error)
                            .padding(.leading, 30)
                            .font(Font.custom("Verlag-Bold", size: 30))
                            .foregroundColor(.customWhite)
                            .padding(.bottom, 10)
                            .padding(.top, 20)
                        if viewModel.isValidCode {
                            Spacer()
                                .padding(.trailing, 140)
                                .frame(alignment: .leading)
                        }
                        Spacer()
                        if !viewModel.isValidCode {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.showAlert = false
                                }
                            }) {
                                Image("Popup_cross_btn")
                            }
                        }
                    }
                    
                    Text(viewModel.isValidCode ? StringConstants.LandingView.validShowCode : StringConstants.LandingView.invalidShowCode)
                        .font(Font.custom("Verlag-Book", size: 18))
                        .padding(.bottom)
                        .foregroundColor(.customWhite)
                    
                    if viewModel.isValidCode {
                        HStack {
                            Text(StringConstants.LandingView.merchandise)
                                .font(Font.custom("Verlag-Bold", size: 20))
                                .foregroundColor(Color.customGreen)
                                .padding(.leading, 30)
                                .onTapGesture {
                                    self.isUserLoggedIn = true
                                    showSeatView = true
                                    isMerchandise = true
                                    viewModel.showAlert = false
                                }
                            Spacer()
                            
                            Text(StringConstants.LandingView.seat)
                                .font(Font.custom("Verlag-Bold", size: 20))
                                .foregroundColor(Color.customGreen)
                                .padding(.trailing, 50)
                                .onTapGesture {
                                    self.isUserLoggedIn = true
                                    showSeatView = true
                                    isMerchandise = false
                                    viewModel.showAlert = false
                                }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                    }
                }
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom)
                .background(Color.FFCE_62)
            }
            
            .customAlert(isPresented: $showSheet) {
                ShowCodeView(showSheet: $showSheet, onCodeEntered: { code in
                    showCode = code
                    Task {
                        await viewModel.validateCode(code)
                    }
                })
                .padding(.bottom)
                .background(Color.clear)
            }

            if showSeatView {
                SeatHomeView(showSeatView: $showSeatView)
                    .zIndex(1)
                    .transition(.move(edge: .top))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut(duration: 0.3), value: showSeatView)
            }
        }
    }
}
