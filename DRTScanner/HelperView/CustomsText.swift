//
//  CustomsText.swift
//  DRTScanner
//
//  Created by IE15 on 07/08/25.
//

import SwiftUI

struct CustomsText: View {
    let title: String
    let textFont: Font
    let foregroundColour: Color
    var alignment: TextAlignment = .leading
    
    var body: some View {
        Text(title)
            .font(textFont)
            .foregroundColor(foregroundColour)
            .multilineTextAlignment(alignment)
    }
}

