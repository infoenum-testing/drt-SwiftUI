//
//  SideMenuOption.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/04/25.
//

import SwiftUI

struct SideMenuOption: View {
    var title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
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
