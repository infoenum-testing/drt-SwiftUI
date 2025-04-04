//
//  InvalidTicketView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 27/03/25.
//


import SwiftUI

struct InvalidTicketView: View {
    var body: some View {
        VStack {            
            VStack {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom)
                
                Text("INVALID SHOW")
                    .font(Font.custom("Verlag-Black", size: 30))
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

#Preview {
    InvalidTicketView()
}
