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
    let isInFullScreen: Bool
    let backGround:Color
    @EnvironmentObject var stringManager: StringManager
    
    var body: some View {
        VStack {
            VStack {
                if isInFullScreen {
                    Spacer()
                } else {
                    VStack {
                        
                    }
                    .frame(height: 0)
                }
                
                
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
                
                let raw = stringManager.strings?.orderDetail.previouslyscanned ?? "PREVIOUSLY SCANNED AT %@"
                Text(raw.replacingOccurrences(of: "%@", with: scannedTime))
                    .font(.verlagBoldAdaptive(size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.primaryText)
                if isInFullScreen {
                    Spacer()
                } else {
                    VStack {
                        
                    }
                    .frame(height: 110)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .frame(height: isInFullScreen ? UIScreen.main.bounds.height : UIScreen.main.bounds.height * 0.6)
        .background(backGround)
              .ignoresSafeArea(edges: .bottom)
              .transition(.opacity)
    }
}

//// Preview
//struct PreviouslyScannedTicketView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviouslyScannedTicketView(orderName: "Order Name", orderNumber: "1234567", scannedTime: "02:16 PM", isInFullScreen: true)
////            .frame(height: UIScreen.main.bounds.height * 0.5)
//    }
//}
