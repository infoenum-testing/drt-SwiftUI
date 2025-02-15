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
    var cellHeight: CGFloat = 80.0
    var bottomLineColor: Color = .gray
    var buttonImage: String
    var buttonAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(imageName)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(Font.custom("Verlag-Book", size: 15))
                    .foregroundColor(.showCodeText)
                Text(subtitle)
                    .font(Font.custom("Verlag-Bold", size: 18))
                    .foregroundColor(.showCodeButton)
            }
            Spacer()
            
            Button(action: {
                buttonAction()
            }) {
                Image(buttonImage)
            }
        }
        .padding()
        .background(.customWhite)
        .frame(height: cellHeight)
        Rectangle()
            .frame(height: 1)
            .foregroundColor(bottomLineColor)
    }
}
