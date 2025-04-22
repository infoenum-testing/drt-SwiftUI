//
//  MerchandiseScanView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 27/03/25.
//


import SwiftUI

struct MerchandiseScanView: View {
    var itemName: String? = nil
    var purchased: Int? = nil
    var scanned: Int? = nil
    var orderName: String? = nil
    var orderNumber: String? = nil

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)

                Text(itemName ?? "")
                    .font(Font.custom("Verlag-Black", size: 30))
                    .foregroundColor(.white)

                VStack(spacing: 5) {
                    Text("Purchased : \(purchased)")
                    Text("Scanned : \(scanned)")
                    Text("Order Name : \(orderName)")
                    Text("Order Number : \(orderNumber)")
                }
                .foregroundColor(.white)
                .font(Font.custom(StringConstants.DRTFont.verlagBold, size: 26))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.top, .bottom], UIScreen.main.bounds.height * 0.11)
            .transition(.opacity)
            .background(Color.green)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0).edgesIgnoringSafeArea(.all))
    }
}

struct MerchandiseScanView_Previews: PreviewProvider {
    static var previews: some View {
        MerchandiseScanView()
    }
}
