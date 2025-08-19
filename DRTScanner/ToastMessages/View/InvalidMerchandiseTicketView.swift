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
                .frame(width: 120.adaptiveForIpad, height: 120.adaptiveForIpad)
                .bold()
                .foregroundColor(Color.primaryText)
                .padding(.bottom)
            CustomsText(title: stringManager.strings.incorrectMode.tickets, textFont: .verlagBlackAdaptive(size: 30), foregroundColour: .primaryText, alignment: .center)
        }
        .frame(width: UIScreen.main.bounds.width)
        .frame(height: UIScreen.main.bounds.height*0.485)
        .background(backGround)
        .ignoresSafeArea(edges: .bottom)
        .transition(.opacity)
    }
}
