//
//  CustomCellView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 04/02/25.
//

// A customizable cell view with an image, title, subtitle, optional button image, and a conditional divider.
// It adapts based on device type (iPad/iPhone) and a @AppStorage value for merchandise mode.

import SwiftUI

struct CustomCellView: View {
    var imageName: String
    var title: String
    var subtitle: String
    var cellHeight: CGFloat
    var bottomLineColor: Color = .gray
    var buttonImage: String
    var showDivider: Bool = true
    var buttonAction: () -> Void
    @AppStorage("isMerchandise") private var isMerchandise: Bool = false

    var body: some View {
        VStack {
            
            Button(action: {
                    buttonAction()
            }) {
                HStack(alignment: .center) {
                    Image(imageName)
                        .resizable()
                        .frame(width: 40.adaptiveForIpad, height: 40.adaptiveForIpad)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.verlagBookAdaptive(size: 15))
                            .foregroundColor(Color.customGreen)
                        Text(subtitle)
                            .font(.verlagBoldAdaptive(size: 18))
                            .foregroundColor(Color.FFCE_62)
                    }
                    Spacer()
                    Image(buttonImage)
                        .resizable()
                        .frame(width: 15.adaptiveForIpad, height: 20.adaptiveForIpad)
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
            }
            
            if showDivider {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    if !isMerchandise {
                        Divider()
                            .frame(height: 8.0)
                            .foregroundColor(bottomLineColor)
                    } else {
                        Divider()
                            .frame(height: dividerHeight())
                            .foregroundColor(bottomLineColor)
                    }
                } else {
                    Divider()
                        .frame(height: dividerHeight())
                        .foregroundColor(bottomLineColor)
                }
            }
        }
        .padding(.horizontal, 0)
        .frame(width: UIScreen.main.bounds.width, height: cellHeight)
        .background(Color.customWhite)
    }
    private func dividerHeight() -> CGFloat {
           if UIDevice.current.userInterfaceIdiom == .pad {
               return isMerchandise ? 0.5 : 0  // If not merchandise on iPad, use thicker divider
           } else {
               return 0.8 // Always 0.5 on iPhone
           }
       }
}
