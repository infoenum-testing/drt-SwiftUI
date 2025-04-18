//
//  InvalidMerchandiseTicketView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 17/04/25.
//


import SwiftUI

struct InvalidMerchandiseTicketView: View {
    var body: some View {
        VStack {
            VStack {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom)
                
                Text("This is an invalid merchandise voucher.")
                    .font(Font.custom("Verlag-Black", size: 30))
                    .multilineTextAlignment(.center)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.top, .bottom], UIScreen.main.bounds.height * 0.18)
            .transition(.opacity)
            .background(Color.red)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0).edgesIgnoringSafeArea(.all))
    }
}
