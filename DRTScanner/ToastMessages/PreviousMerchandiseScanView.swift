//
//  PreviousMerchandiseScanView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 27/03/25.
//


import SwiftUI

struct PreviousMerchandiseScanView: View {
    var itemName: String = "TSHIRT MEDIUM"
    var purchased: Int = 3
    var scanned: Int = 3
    var orderName: String = "John Doe"
    var orderNumber: String = "1234567"

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80.adaptiveForIpad, height: 80.adaptiveForIpad)
                    .foregroundColor(.white)

                Text(StringConstants.DRTToastMessages.preScanned)
                    .font(.verlagBlackAdaptive(size: 30))
                    .foregroundColor(.white)

                Text(itemName)
                    .font(.verlagBoldAdaptive(size: 26))
                    .foregroundColor(.white)

                VStack(spacing: 5) {
                    Text("Purchased : \(purchased)")
                    Text("Scanned : \(scanned)")
                    Text("Order Name : \(orderName)")
                    Text("Order Number : \(orderNumber)")
                }
                .foregroundColor(.white)
                .font(.verlagBoldAdaptive(size: 24))
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.top], UIDevice.current.userInterfaceIdiom == .pad ? 10 : UIScreen.main.bounds.height * 0.11)
            .padding([.bottom], UIDevice.current.userInterfaceIdiom == .pad ? 0 : UIScreen.main.bounds.height * 0.11)
            .transition(.opacity)
            .background(Color(red: 0.99, green: 0.35, blue: 0.0))
//            .padding(.top)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0).edgesIgnoringSafeArea(.all))
    }
}

struct PreviousMerchandiseScanView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousMerchandiseScanView()
    }
}
