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
    let isInFullScreen: Bool
    
    var body: some View {
        VStack {
            
            VStack(spacing: 15) {
                if isInFullScreen {
                    Spacer()
                } else {
                    VStack {
                        
                    }
                    .frame(height: 0)
                }
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
        .background(isGoldenTicket ? Color(red: 1.0, green: 0.84, blue: 0.0) : Color.validCustomGreen)
        .transition(.opacity)
    }
}
