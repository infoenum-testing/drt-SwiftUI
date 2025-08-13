//
//  InvalidSeatTicketView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 17/04/25.
//


import SwiftUI

struct InvalidSeatTicketView: View {
    let message: String
    let isInFullScreen: Bool
    @EnvironmentObject var stringManager: StringManager
    let backGround: Color
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
                    .foregroundColor(Color.primaryText)
                    .padding(.bottom)
                
                Text(stringManager.strings.incorrectMode.merch)
                    .font(.verlagBlackAdaptive(size: 30))
                    .multilineTextAlignment(.center)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primaryText)
                
                if isInFullScreen {
                    Spacer()
                } else {
                    VStack {
                        
                    }
                    .frame(height: 110)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .frame(height: isInFullScreen ? UIScreen.main.bounds.height : UIScreen.main.bounds.height * 0.6)
        .background(backGround)
        .ignoresSafeArea(edges: .bottom)
        .transition(.opacity)
    }
}
