//
//  GoOnlineView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 04/03/25.
//


import SwiftUI

struct GoOnlineView: View {
    @Binding var isPresented: Bool
    @State private var progress: CGFloat = 0.0
    @State private var isUploading = true
    @State private var showSuccessMessage = false
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = true
    @AppStorage("deviceScanCount") private var deviceScanCount: Int = 0
    @EnvironmentObject var stringManager: StringManager
    
    var body: some View {
        if !showErrorMessage {
            ZStack {
                AppBackGroundView(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height * 0.35,shadow: true)
                VStack(spacing: 20) {
                    Spacer()
                    if !showErrorMessage {
                        Text(stringManager.strings?.menu.goOnline ?? StringConstants.SideMenuView.goOnline)
                            .font(.verlagBoldAdaptive(size: 30))
                            .foregroundColor(Color.primaryText)
                    }
                    if isUploading {
                        Text(stringManager.strings?.dialogGoOnline.uploading ?? StringConstants.SideMenuView.goOnlineServer)
                            .font(.verlagBookAdaptive(size: 18))
                            .foregroundColor(Color.primaryText)
                            .multilineTextAlignment(.leading)
                            .padding()
                        if !showErrorMessage {
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                                    .scaleEffect(1.0)
                                
                                ProgressView(value: progress, total: 1.0)
                                    .progressViewStyle(LinearProgressViewStyle(tint: Color.primaryText))
                                    .background(Color.neutralBg)
                                    .foregroundColor(.primaryText)
                                    .padding()
                                    .animation(.easeInOut, value: progress)
                                    .onAppear {
                                        startUpload() // Starts the upload process when view appears
                                    }
                                
                                Text("\(Int(progress * 100))% Completed")
                                    .font(.verlagBoldAdaptive(size: 16))
                                    .foregroundColor(Color.primaryText)
                                
                            }
                        }
                    } else if showSuccessMessage {
                        Text(stringManager.strings?.offline.uploaded ?? StringConstants.SideMenuView.goOnlineSuccess)
                            .font(.verlagBoldAdaptive(size: 22))
                            .foregroundColor(Color.primaryText)
                    }  else if showErrorMessage {
                        Text(stringManager.strings?.dialogGoOffline.goOnlineFailed ?? StringConstants.SideMenuView.goOnlineFailed)
                            .font(.verlagBoldAdaptive(size: 18))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height * 0.35)
        } else {
            VStack {
                CustomAlertForError(isPresented: $showErrorMessage, message: errorMessage)
                Spacer()
            }
        }
    }
    
    private func startUploadWithoutApi() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if progress < 1.0 {
                progress += 0.2
            } else {
                timer.invalidate()
                isUploading = false
                showSuccessMessage = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isOfflineMode = false
                    isPresented = false
                }
            }
        }
    }
    
    func startUpload() {
        DRTDatabaseManager.shared.fetchDataAndPostToServer { success, error in
            if success {
                progress = 1.0
                isUploading = false
                showSuccessMessage = true
                isOfflineMode = false
                deviceScanCount = 0
                print(isOfflineMode)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    isPresented = false
                }
            } else {
                errorMessage = error?.localizedDescription ?? "Unknown error"
                showErrorMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    isPresented = false
                }
            }
        }
        
        // Simulates progress bar animation
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if progress < 1.0 {
                progress += 0.2
            } else {
                timer.invalidate()
            }
        }
    }
}

// Custom alert view for displaying error messages
struct CustomAlertForError: View {
    @Binding var isPresented: Bool
    var message: String
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Text(StringManager.shared.strings?.errorMassage.error ?? StringConstants.Common.error)
                    .font(.verlagBoldAdaptive(size: 30))
                    .foregroundColor(Color.primaryText)
                    .padding(.bottom, 5)
                    .padding(.top, topSafeAreaPadding())
                Spacer()
            }
            
            VStack {
                let finalMessage = NetworkMonitor.shared.isNetworkAvailable() ? message : StringManager.shared.strings?.noInternet.description ?? StringConstants.Common.noInternetError
                Text(finalMessage)
                    .font(.verlagBookAdaptive(size: 18))
                    .foregroundColor(Color.primaryText)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 5)
        .background(Color.secondaryBg)
        .opacity(isPresented ? 1 : 0)
    }
}
