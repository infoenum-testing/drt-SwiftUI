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
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .bold()
                    .foregroundColor(.white)

                Text(orderName.capitalized)
                    .font(Font.custom("Verlag-Black", size: 30))
                    .foregroundColor(.white)

                Text("Order: \(orderNumber)")
                    .font(Font.custom("Verlag-Bold", size: 26))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.top, .bottom], UIScreen.main.bounds.height * 0.15)
            .background(Color.green)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3))
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0).edgesIgnoringSafeArea(.all))
    }
}
