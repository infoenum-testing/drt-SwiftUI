//
//  MerchandiseScanView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 27/03/25.
//


import SwiftUI

struct MerchandiseScanView: View {
    var variantName: String
    var name: String

    var body: some View {
        VStack {
            VStack {
                Spacer().padding()
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
                Spacer().padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.top, .bottom], UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.1 : 0.12))
            .transition(.opacity)
            .background(Color.green)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0).edgesIgnoringSafeArea(.all))
    }
}
