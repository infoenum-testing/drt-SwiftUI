//
//  SideMenuOption.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/04/25.
//

import SwiftUI

struct SideMenuOption: View {
    let imageName: String
    var title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 10) {
            Image(imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .frame(width: 20.adaptiveForIpad, height: 20.adaptiveForIpad)
                
            Text(title)
                .font(.verlagBoldAdaptive(size: 16))
                .foregroundColor(Color.primaryText)
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
