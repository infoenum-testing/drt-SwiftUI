//
//  InvalidSeatTicketView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 17/04/25.
//


import SwiftUI

struct InvalidSeatTicketView: View {
    @EnvironmentObject var stringManager: StringManager
    let backGround: Color
    var body: some View {
        VStack {
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
                .padding(.horizontal, 10)
        }
        .frame(width: UIScreen.main.bounds.width)
        .frame(height: UIDevice.isIpad ? (UIDevice.isLandscape ? UIScreen.main.bounds.height*0.485 : resultSheetHeightForIpad()) : resultSheetHeightForIphone())
        .background(backGround)
        .ignoresSafeArea(edges: .bottom)
        .transition(.opacity)
    }
}
