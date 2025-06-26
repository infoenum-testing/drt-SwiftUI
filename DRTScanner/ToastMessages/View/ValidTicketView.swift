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
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Image("circle_and_check_icon")
                    .resizable()
                    .frame(width: 120.adaptiveForIpad, height: 120.adaptiveForIpad)
                    .bold()
                    .foregroundColor(.white)

                Text(orderName.capitalized)
                    .font(.verlagBlackAdaptive(size: 30))
                    .foregroundColor(.white)

                if orderNumber != "0" {
                    Text("Order: \(orderNumber)")
                        .font(.verlagBoldAdaptive(size: 26))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.top, .bottom], UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.1 : 0.17))
            .background(isGoldenTicket ? Color(red: 1.0, green: 0.84, blue: 0.0) : Color.green)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3))
//            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0).edgesIgnoringSafeArea(.all))
    }
}
