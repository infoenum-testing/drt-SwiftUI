//
//  MerchandiseScanView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 27/03/25.
//


import SwiftUI

struct MerchandiseScanView: View {
    let variantName: String
    let name: String
    let isInFullScreen: Bool
    var body: some View {
        VStack {
            VStack {
                if isInFullScreen {
                    Spacer()
                } else {
                    VStack {
                        
                    }
                    .frame(height: 0)
                }
                Image("circle_and_check_icon")
                    .resizable()
                    .frame(width: 100.adaptiveForIpad, height: 100.adaptiveForIpad)
                    .foregroundColor(.white)
                    .padding(.top, -10.adaptiveForIpad)

                VStack(spacing: 5) {
                    Text("\(name)")
                    if variantName != "" {
                        Text("Variant Name : \(variantName)")
                    }
                }
                .foregroundColor(.white)
                .font(.verlagBoldAdaptive(size: 26))
                if isInFullScreen {
                    Spacer()
                } else {
                    VStack {
                        
                    }
                    .frame(height: 110)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: isInFullScreen ? UIScreen.main.bounds.height : UIScreen.main.bounds.height * 0.6)
        .background(Color.green)
        .ignoresSafeArea(edges: .bottom)
        .transition(.opacity)
    }
}
