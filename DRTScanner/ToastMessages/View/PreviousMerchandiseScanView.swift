//
//  PreviousMerchandiseScanView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 27/03/25.
//

import SwiftUI

struct PreviousMerchandiseScanView: View {
    let name: String
    let variantName: String
    let message: String
    let tsScannedDate: String
    let isInFullScreen: Bool
    @EnvironmentObject var stringManager: StringManager
    let backGround:Color
    var body: some View {
        VStack {
            if isInFullScreen {
                Spacer()
            }
            VStack(spacing: 20) {
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

                VStack(spacing: 8) {
                    Text(name)
                        .font(.verlagBlackAdaptive(size: 30))
                        .foregroundColor(Color.primaryText)
                    if variantName != "" {
                        Text("Variant name: \(variantName)")
                            .font(.verlagBoldAdaptive(size: 26))
                            .foregroundColor(Color.primaryText)
                    }
                    if let scanDate = tsScannedDate.toDateFromMillisecondsTimestamp() {
                        CustomsText(title: String.getScanLabel(from: scanDate) , textFont: .verlagBoldAdaptive(size: 26), foregroundColour: .primaryText, alignment: .center)
                    } else  if let scanDate = Date.todayAtTime(message) {
                        CustomsText(title: String.getScanLabel(from: scanDate) , textFont: .verlagBoldAdaptive(size: 26), foregroundColour: .primaryText, alignment: .center)
                    }
                }

                if isInFullScreen {
                    Spacer()
                } else {
                    VStack {
                        
                    }
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
}

