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
    
    var body: some View {
        VStack {
            VStack {
                Image("circle_and_!_icon")
                    .resizable()
                    .frame(width: 120.adaptiveForIpad, height: 120.adaptiveForIpad)
                    .bold()
                    .foregroundColor(Color.primaryText)
                    .padding([.top, .bottom], 5)
                
                Text(orderName.capitalized)
                    .font(.verlagBlackAdaptive(size: 30))
                    .foregroundColor(Color.primaryText)
                    .multilineTextAlignment(.center)
                
                if orderNumber != "0" {
                    Text("Order: \(orderNumber)")
                        .font(.verlagBoldAdaptive(size: 26))
                        .foregroundColor(Color.primaryText)
                }
                
                if let scanDate = tsScannedDate.toDateFromMillisecondsTimestamp() {
                    CustomsText(title: String.getScanLabel(from: scanDate) , textFont: .verlagBoldAdaptive(size: 26), foregroundColour: .primaryText, alignment: .center)
                } else  if let scanDate = Date.todayAtTime(scannedTime) {
                    CustomsText(title: String.getScanLabel(from: scanDate) , textFont: .verlagBoldAdaptive(size: 26), foregroundColour: .primaryText, alignment: .center)
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .frame(height: UIScreen.main.bounds.height*0.485)
            .background(backGround)
            .ignoresSafeArea(edges: .bottom)
            .transition(.opacity)
        }
    }
}
