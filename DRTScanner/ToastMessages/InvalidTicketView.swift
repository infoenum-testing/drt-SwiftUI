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
                Spacer()
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: 120.adaptiveForIpad, height: 120.adaptiveForIpad)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom)
                
                Text(StringConstants.DRTToastMessages.inValidShow)
                    .font(.verlagBlackAdaptive(size: 30))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.top, .bottom], UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.height * 0.10 : UIScreen.main.bounds.height * 0.18)
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
