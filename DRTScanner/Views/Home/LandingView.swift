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
    @State private var showCode: String = "289-6385"
    
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
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSheet = true
                    }
                }) {
                    Text(StringConstants.LandingView.showCode)
                        .font(Font.custom("Verlag-Bold", size: 18))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(.showCodeButton)
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
//                if DRTUser.isUserLoggedIn {
//                    showSeatView = true
//                }
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
                            Text("Merchandise")
                                .font(Font.custom("Verlag-Bold", size: 20))
                                .foregroundColor(.showCodeText)
                                .padding(.leading, 30)
                            Spacer()
                            
                            Text("Seat")
                                .font(Font.custom("Verlag-Bold", size: 20))
                                .foregroundColor(.showCodeText)
                                .padding(.trailing, 50)
                                .onTapGesture {
                                    showSeatView = true
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
                .padding(.bottom)
                .background(Color.showCodeButton)
            }
            
                .customAlert(isPresented: $showSheet) {
                    ShowCodeView(showSheet: $showSheet, onCodeEntered: { code in
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

#Preview {
    LandingView()
}
