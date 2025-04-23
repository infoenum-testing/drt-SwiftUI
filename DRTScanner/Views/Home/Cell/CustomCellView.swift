//
//  CustomCellView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 04/02/25.
//


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

    var body: some View {
        HStack(spacing: 12) {
            
            Button(action: {
                    buttonAction()
            }) {
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
        }
        .padding()
        .background(Color.customWhite)
        .frame(height: cellHeight)
        .frame(width: UIScreen.main.bounds.width)
        if showDivider {
            Divider()
                .frame(height: 0.5)
                .foregroundColor(bottomLineColor)
        }
    }
}
