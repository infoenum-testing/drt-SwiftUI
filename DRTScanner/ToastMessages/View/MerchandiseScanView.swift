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
    let backGround:Color
    var body: some View {
        VStack {
            VStack {
             
                Image("circle_and_check_icon")
                    .resizable()
                    .frame(width: 100.adaptiveForIpad, height: 100.adaptiveForIpad)
                    .foregroundColor(Color.primaryText)
                    .padding(.top, -10.adaptiveForIpad)
                
                VStack(spacing: 5) {
                    Text("\(name)")
                    if variantName != "" {
                        Text("Variant Name : \(variantName)")
                    }
                }
                .foregroundColor(Color.primaryText)
                .font(.verlagBoldAdaptive(size: 26))
            }
            .frame(width: UIScreen.main.bounds.width)
            .frame(height: UIScreen.main.bounds.height*0.485)
            .background(backGround)
            .ignoresSafeArea(edges: .bottom)
            .transition(.opacity)
        }
    }
}
