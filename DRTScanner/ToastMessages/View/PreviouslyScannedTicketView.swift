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
    let tsScannedDate: String
    let backGround:Color
    @EnvironmentObject var stringManager: StringManager
    let action: ()-> Void

    var body: some View {
        VStack {
            Image("circle_and_!_icon")
                .resizable()
                .frame(width: 120.adaptiveForIpad, height: 120.adaptiveForIpad)
                .bold()
                .foregroundColor(Color.primaryText)
                .padding([.top, .bottom], 5)
            if orderNumber != "0" {
                Text("\(orderNumber)")
                    .font(.verlagBoldAdaptive(size: 26))
                    .foregroundColor(Color.primaryText)
                    .padding(.horizontal, 10)

            }
            
            Text("Buyer: \(orderName.capitalized)")
                .font(.verlagBoldAdaptive(size: 26))
                .foregroundColor(Color.primaryText)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5.adaptiveForIpad)
            
            
            if let scanDate = tsScannedDate.toDateFromMillisecondsTimestamp() {
                CustomsText(title: String.getScanLabel(from: scanDate) , textFont: .verlagBoldAdaptive(size: 26), foregroundColour: .primaryText, alignment: .center)
                    .padding(.horizontal, 10)

            } else  if let scanDate = Date.todayAtTime(scannedTime) {
                CustomsText(title: String.getScanLabel(from: scanDate) , textFont: .verlagBoldAdaptive(size: 26), foregroundColour: .primaryText, alignment: .center)
                    .padding(.horizontal, 10)

            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .frame(height: UIDevice.isIpad ? (UIDevice.isLandscape ? UIScreen.main.bounds.height*0.485 : resultSheetHeightForIpad()) : resultSheetHeightForIphone())
        .background(backGround)
        .ignoresSafeArea(edges: .bottom)
        .transition(.opacity)
        .onTapGesture {
            action()
        }
    }
}
