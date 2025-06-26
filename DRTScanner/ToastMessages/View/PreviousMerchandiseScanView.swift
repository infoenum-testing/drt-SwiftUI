//
//  PreviousMerchandiseScanView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 27/03/25.
//


import SwiftUI

//struct PreviousMerchandiseScanView: View {
//    var name: String
//    var variantName: String
//    var message: String
//
//    var body: some View {
//        VStack {
//            VStack(spacing: 16) {
//                Spacer()
//                Image("circle_and_!_icon")
//                    .resizable()
//                    .frame(width: 100.adaptiveForIpad, height: 100.adaptiveForIpad)
//                    .foregroundColor(.white)
//
//
//                VStack(spacing: 5) {
//                    Text("\(name)")
//                    Text("Variant name: \(variantName)")
//                    Text("\(message)")
//                }
//                .foregroundColor(.white)
//                .font(.verlagBoldAdaptive(size: 24))
//                Spacer()
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .padding([.top], UIDevice.current.userInterfaceIdiom == .pad ? 10 : UIScreen.main.bounds.height * 0.11)
//            .padding([.bottom], UIDevice.current.userInterfaceIdiom == .pad ? 0 : UIScreen.main.bounds.height * 0.11)
//            .transition(.opacity)
//            .background(Color(red: 0.99, green: 0.35, blue: 0.0))
////            .padding(.top)
//
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.black.opacity(0).edgesIgnoringSafeArea(.all))
//    }
//}

import SwiftUI

struct PreviousMerchandiseScanView: View {
    var name: String
    var variantName: String
    var message: String

    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.35, blue: 0.0) // Background color
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Spacer()
                Image("circle_and_!_icon")
                    .resizable()
                    .frame(width: 100.adaptiveForIpad, height: 100.adaptiveForIpad)
                    .foregroundColor(.white)

                VStack(spacing: 8) {
                    Text(name)
                    if variantName != "" {
                        Text("Variant name: \(variantName)")
                    }
                    Text(message)
                }
                .foregroundColor(.white)
                .font(.verlagBoldAdaptive(size: 24))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.top], UIDevice.current.userInterfaceIdiom == .pad ? 10 : UIScreen.main.bounds.height * 0.11)
            .padding([.bottom], UIDevice.current.userInterfaceIdiom == .pad ? 0 : UIScreen.main.bounds.height * 0.11)
            .transition(.opacity)
            .background(Color(red: 0.99, green: 0.35, blue: 0.0))
//            .padding(.top)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    VStack {
        Spacer()
        PreviousMerchandiseScanView(
            name: "Test Product",
            variantName: "N/A",
            message: "This item was already scanned."
        )
        .frame(height: UIScreen.main.bounds.height * 0.5)
    }
    .background(Color.black.opacity(0.4))
    .ignoresSafeArea()
}
