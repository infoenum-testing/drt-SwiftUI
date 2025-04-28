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
            VStack {
                Spacer().padding()
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80.adaptiveForIpad, height: 80.adaptiveForIpad)
                    .foregroundColor(.white)
                    .padding(.top, -10.adaptiveForIpad)

                Text(itemName ?? "")
                    .font(.verlagBlackAdaptive(size: 30))
                    .foregroundColor(.white)

                VStack(spacing: 5) {
                    Text("Purchased : \(purchased)")
                    Text("Scanned : \(scanned)")
                    Text("Order Name : \(orderName)")
                    Text("Order Number : \(orderNumber)")
                }
                .foregroundColor(.white)
                .font(.verlagBoldAdaptive(size: 26))
                Spacer().padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.top, .bottom], UIScreen.main.bounds.height * (UIDevice.current.userInterfaceIdiom == .pad ? 0.1 : 0.12))
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
