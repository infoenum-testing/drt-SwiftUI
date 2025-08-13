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
            if isInFullScreen {
                Spacer()
            }
            VStack {
                if isInFullScreen {
                    Spacer()
                } else {
                    VStack {}
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
                
                if let scanDate = Date.todayAtTime(scannedTime) {
                    CustomsText(title: getScanLabel(from: scanDate), textFont: .verlagBoldAdaptive(size: 26), foregroundColour: .primaryText, alignment: .center)
                        .multilineTextAlignment(.center)
                }
                if isInFullScreen {
                    Spacer()
                } else {
                    VStack {}
                    .frame(height: 110)
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .frame(height: isInFullScreen ? UIScreen.main.bounds.height*0.47 : UIScreen.main.bounds.height * 0.6)
            .background(backGround)
            .ignoresSafeArea(edges: .bottom)
            .transition(.opacity)
        }
    }

    func getScanLabel(from scanDate: Date, isFirstScan: Bool = false) -> String {
        let now = Date()
        let diffSeconds = Int(now.timeIntervalSince(scanDate))
        let diffMinutes = diffSeconds / 60
        let diffHours = diffMinutes / 60
        let diffDays = diffHours / 24


        let labelTemplate = isFirstScan ? stringManager.strings.orderDetail.scanned : stringManager.strings.orderDetail.previouslyScanned

        switch diffMinutes {
        case ..<2:
            return String(format: labelTemplate, stringManager.strings.orderDetail.justNow)
        case 2..<60:
            let timeLabel = String(format: stringManager.strings.orderDetail.minsAgo, "\(diffMinutes)")
            return String(format: labelTemplate, timeLabel)
        case 60..<1440:
            let timeLabel = String(format: stringManager.strings.orderDetail.hoursAgo, "\(diffHours)")
            return String(format: labelTemplate, timeLabel)
        default:
            let timeLabel = String(format: stringManager.strings.orderDetail.daysAgo, "\(diffDays)")
            return String(format: labelTemplate, timeLabel)
        }
    }
}
