//
//  ValidTicketView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 27/03/25.
//

import SwiftUI

struct ValidTicketView: View {
    let orderName: String
    let orderNumber: String
    let isGoldenTicket: Bool
    let backGround: Color
    let action: ()-> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Image("circle_and_check_icon")
                .resizable()
                .frame(width: 120.adaptiveForIpad, height: 120.adaptiveForIpad)
                .bold()
                .foregroundColor(Color.primaryText)
            
            Text(orderName.capitalized)
                .font(.verlagBlackAdaptive(size: 30))
                .foregroundColor(Color.primaryText)
                .padding(.horizontal, 10)
            
            if orderNumber != "0" {
                Text("Order: \(orderNumber)")
                    .font(.verlagBoldAdaptive(size: 26))
                    .foregroundColor(Color.primaryText)
                    .padding(.horizontal, 10)

            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .frame(height: UIDevice.isIpad ? (UIDevice.isLandscape ? UIScreen.main.bounds.height*0.485 : resultSheetHeightForIpad()) : resultSheetHeightForIphone())
        .background(isGoldenTicket ? Color.colorGoldenTicket : backGround)
        .transition(.opacity)
        .onTapGesture {
            action()
        }
    }
}
