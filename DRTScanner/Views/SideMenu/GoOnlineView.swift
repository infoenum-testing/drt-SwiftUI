//
//  GoOnlineView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 04/03/25.
//


import SwiftUI

import SwiftUI

struct GoOnlineView: View {
    @Binding var isPresented: Bool
    @State private var progress: CGFloat = 0.0
    @State private var isUploading = true
    @State private var showSuccessMessage = false
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
                
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .background(.customWhite)
                    .frame(width: 200)
                    .onAppear {
                        startUpload()
                    }
            } else if showSuccessMessage {
                Text("Upload Successful!")
                    .font(Font.custom("Verlag-Bold", size: 22))
                    .foregroundColor(.customWhite)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3)
        .background(Color.showCodeButton)
    }
    
    private func startUpload() {
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
}
