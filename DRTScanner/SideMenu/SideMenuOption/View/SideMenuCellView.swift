//
//  SideMenuOption.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/04/25.
//

import SwiftUI

struct SideMenuCellView: View {
    let imageName: String
    var title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 10) {
            if imageName == "settingweb" {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.primaryText)
                    .frame(width: 30.adaptiveForIpad, height: 20.adaptiveForIpad)
            } else {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.primaryText)
                    .frame(width: 20.adaptiveForIpad, height: 20.adaptiveForIpad)
            }
            CustomsText(title: title, textFont: .verlagBoldAdaptive(size: 16), foregroundColour: .primaryText)

            Spacer()
        }
        .padding(UIDevice.current.userInterfaceIdiom == .pad ? 30 : 20)
        .frame(maxWidth: .infinity)
        .background(Color.primaryBg)
        .onTapGesture {
            action?()
        }
    }
}
