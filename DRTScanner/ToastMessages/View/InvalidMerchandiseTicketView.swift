//
//  InvalidMerchandiseTicketView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 17/04/25.
//


import SwiftUI

struct InvalidMerchandiseTicketView: View {
    @EnvironmentObject var stringManager: StringManager
    let backGround: Color
    var body: some View {
        VStack {
            Image("circle_and_cross_icon")
                .resizable()
                .frame(width: UIDevice.isNonNotchIphone ? 90 : 120.adaptiveForIpad, height: UIDevice.isNonNotchIphone ? 90 : 120.adaptiveForIpad)
                .bold()
                .foregroundColor(Color.primaryText)
                .padding(.bottom)
            
            CustomsText(title: stringManager.strings.incorrectMode.incorrectMode, textFont: .verlagBlackAdaptive(size: 30), foregroundColour: .primaryText, alignment: .center)
                .padding(.horizontal, 10)         
            CustomsText(title: stringManager.strings.incorrectMode.tickets, textFont: .verlagBookAdaptive(size: 20), foregroundColour: .primaryText, alignment: .center)
                .padding(.horizontal, 50)

        }
        .frame(width: UIScreen.main.bounds.width)
        .frame(height: UIDevice.isIpad ? (UIDevice.isLandscape ? UIScreen.main.bounds.height*0.485 : resultSheetHeightForIpad()) : resultSheetHeightForIphone())
        .background(backGround)
        .ignoresSafeArea(edges: .bottom)
        .transition(.opacity)
    }
}
