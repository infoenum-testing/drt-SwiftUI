//
//  PreviouslyScannedTicketView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 27/03/25.
//


import SwiftUI

struct PreviouslyScannedTicketView: View {
    let orderName: String
    let orderNumber: String
    let scannedTime: String

    var body: some View {
        VStack {            
            VStack(spacing: 15) {
                Image(systemName: "exclamationmark.circle")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .bold()
                    .foregroundColor(.white)
                
                Text(orderName.capitalized)
                    .font(Font.custom("Verlag-Black", size: 30))
                    .foregroundColor(.white)
                
                Text("Order: \(orderNumber)")
                    .font(Font.custom(StringConstants.DRTFont.verlagBold, size: 26))
                    .foregroundColor(.white)
                
                Text("Previously Scanned @\n\(scannedTime)")
                    .font(Font.custom(StringConstants.DRTFont.verlagBold, size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.top, .bottom], UIScreen.main.bounds.height * 0.11)
            .transition(.opacity)
            .background(Color(red: 0.99, green: 0.35, blue: 0.0))
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0).edgesIgnoringSafeArea(.all))
    }
}

// Preview
struct PreviouslyScannedTicketView_Previews: PreviewProvider {
    static var previews: some View {
        PreviouslyScannedTicketView(orderName: "Order Name", orderNumber: "1234567", scannedTime: "02:16 PM")
    }
}
