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
            VStack {
                Spacer()
                Image(systemName: "exclamationmark.circle")
                    .resizable()
                    .frame(width: 120.adaptiveForIpad, height: 120.adaptiveForIpad)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 5)
                
                Text(orderName.capitalized)
                    .font(.verlagBlackAdaptive(size: 30))
                    .foregroundColor(.white)
                
                Text("Order: \(orderNumber)")
                    .font(.verlagBoldAdaptive(size: 26))
                    .foregroundColor(.white)
                
                Text("Previously Scanned @\n\(scannedTime)")
                    .font(.verlagBoldAdaptive(size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.top, .bottom], UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.03 : 0.11))
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
