//
//  PreviousMerchandiseScanView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 27/03/25.
//

import SwiftUI

struct PreviousMerchandiseScanView: View {
    let name: String
    let variantName: String
    let message: String
    let isInFullScreen: Bool
    @EnvironmentObject var stringManager: StringManager

    var body: some View {
        VStack {
            VStack(spacing: 20) {
                if isInFullScreen {
                    Spacer()
                } else {
                    VStack {
                        
                    }
                    .frame(height: 0)
                }
                Image("circle_and_!_icon")
                    .resizable()
                    .frame(width: 120.adaptiveForIpad, height: 120.adaptiveForIpad)
                    .bold()
                    .foregroundColor(.white)
                    .padding([.top, .bottom], 5)

                VStack(spacing: 8) {
                    Text(name)
                        .font(.verlagBlackAdaptive(size: 30))
                        .foregroundColor(.white)
                    if variantName != "" {
                        Text("Variant name: \(variantName)")
                            .font(.verlagBoldAdaptive(size: 26))
                            .foregroundColor(.white)
                    }
                    let raw = stringManager.strings?.orderDetail.previouslyscanned ?? "PREVIOUSLY SCANNED AT %@"
                    Text(raw.replacingOccurrences(of: "%@", with: message))
                        .font(.verlagBoldAdaptive(size: 26))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                }

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
        .background(Color.customOrange)
        .ignoresSafeArea(edges: .bottom)
        .transition(.opacity)
    }
}

#Preview {
    VStack {
        Spacer()
        PreviousMerchandiseScanView(
            name: "Test Product",
            variantName: "N/A",
            message: "This item was already scanned.", isInFullScreen: true
        )
        .frame(height: UIScreen.main.bounds.height * 0.5)
    }
    .background(Color.black.opacity(0.4))
    .ignoresSafeArea()
}
