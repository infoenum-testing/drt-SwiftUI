//
//  InvalidTicketView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 27/03/25.
//


import SwiftUI

struct InvalidTicketView: View {
    let message: String
    let backGround:Color
    var body: some View {
        VStack {
            
            VStack {
             
                Image("circle_and_cross_icon")
                    .resizable()
                    .frame(width: 120.adaptiveForIpad, height: 120.adaptiveForIpad)
                    .bold()
                    .foregroundColor(Color.primaryText)
                    .padding(.bottom)
                
                Text(message)
                    .font(.verlagBlackAdaptive(size: 30))
                    .multilineTextAlignment(.center)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primaryText)
            }
            .frame(width: UIScreen.main.bounds.width)
            .frame(height: UIScreen.main.bounds.height*0.485)
            .background(backGround)
            .ignoresSafeArea(edges: .bottom)
            .transition(.opacity)
        }
    }
}
