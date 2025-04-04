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
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = true
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Go Online")
                .font(Font.custom("Verlag-Bold", size: 30))
                .foregroundColor(.customWhite)
            
            if isUploading {
                Text("Uploading scanned tickets to the server...")
                    .font(Font.custom("Avenir-Light", size: 18))
                    .foregroundColor(.customWhite)
                    .multilineTextAlignment(.leading)
                    .padding()
                
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
                            startUpload()
                        }
                    
                    Text("\(Int(progress * 100))% Completed")
                        .font(Font.custom("Verlag-Bold", size: 16))
                        .foregroundColor(.white)
                }
                   
            } else if showSuccessMessage {
                Text("Upload Successful!")
                    .font(Font.custom("Verlag-Bold", size: 22))
                    .foregroundColor(.customWhite)
            }  else if showErrorMessage {
                Text("Database upload failed! Please try again.")
                    .font(Font.custom("Verlag-Bold", size: 18))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3)
        .background(Color.FFCE_62)
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
                print(isOfflineMode)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                   
                    isPresented = false
                }
            } else {
                //showSuccessMessage = false
                showErrorMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    isPresented = false
                }
                print("Upload failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if progress < 1.0 {
                progress += 0.2
            } else {
                timer.invalidate()
            }
        }
    }
}
