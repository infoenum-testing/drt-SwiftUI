//
//  InvalidTicketView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 27/03/25.
//


import SwiftUI

struct InvalidTicketView: View {
    let message: String
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
                Image("circle_and_cross_icon")
                    .resizable()
                    .frame(width: 120.adaptiveForIpad, height: 120.adaptiveForIpad)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom)
                
                Text(message)
                    .font(.verlagBlackAdaptive(size: 30))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
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
        .background(Color.red)
        .ignoresSafeArea(edges: .bottom)
        .transition(.opacity)
    }
}
