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
    
    var body: some View {
        VStack(spacing: 20) {
            if !showErrorMessage {
                Text(StringConstants.SideMenuView.goOnline)
                    .font(.verlagBoldAdaptive(size: 30))
                    .foregroundColor(.customWhite)
            }
            if isUploading {
                Text(StringConstants.SideMenuView.goOnlineServer)
                    .font(.verlagBookAdaptive(size: 18))
                    .foregroundColor(.customWhite)
                    .multilineTextAlignment(.leading)
                    .padding()
                if !showErrorMessage {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.0)
                        
                        ProgressView(value: progress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .background(Color.customWhite)
                            .foregroundColor(.customWhite)
                            .padding()
                            .animation(.easeInOut, value: progress)
                            .onAppear {
                                startUpload() // Starts the upload process when view appears
                               
                            }
                        
                        Text("\(Int(progress * 100))% Completed")
                            .font(.verlagBoldAdaptive(size: 16))
                            .foregroundColor(.white)
                        
                    }
                  
                }
                   
            } else if showSuccessMessage {
                Text(StringConstants.SideMenuView.goOnlineSuccess)
                    .font(.verlagBoldAdaptive(size: 22))
                    .foregroundColor(.customWhite)
            }  else if showErrorMessage {
                Text(StringConstants.SideMenuView.goOnlineFailed)
                    .font(.verlagBoldAdaptive(size: 18))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3)
        .background(Color.FFCE_62)
        .overlay(CustomAlertForError(isPresented: $showErrorMessage, message: errorMessage), alignment: .center)
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
                Text(StringConstants.Common.error)
                    .font(.verlagBoldAdaptive(size: 30))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                    .padding(.top, 20)
                Spacer()
            }

            VStack {
                Text(message)
                    .font(.verlagBookAdaptive(size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .padding()
        .background(Color.FFCE_62)
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 5)
        .opacity(isPresented ? 1 : 0)
    }
}
