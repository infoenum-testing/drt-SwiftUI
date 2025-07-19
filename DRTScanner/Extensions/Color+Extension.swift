//
//  Color+Extension.swift
//  DRTScanner
//
//  Created by IE15 on 14/07/25.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = ((int >> 24) & 0xff, (int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    // Convenience alias so we don’t repeat the lookup.
    private static var palette: SkinModel { ColorManager.shared.skin ?? SkinModel(
        colorValid:       "4F8C3B",
        colorNeutralText: "333333",
        colorNeutralBg:   "C3C3C3",
        color1Text:       "FFFFFF",
        backgroundHref:   "",
        colorInvalid:     "FF4242",
        colorPrevious:    "FCB638",
        color2Bg:         "FFCE62",
        color1Bg:         "74B9AE",
        color2Text:       "FFFFFF",
        logoHref:         ""
    )}
  
    static var valid:            Color { Color(hex: palette.colorValid) }
    static var invalid:          Color { Color(hex: palette.colorInvalid) }
    static var previous:         Color { Color(hex: palette.colorPrevious) }
    
    // black , gray
    static var neutralText:      Color { Color(hex: palette.colorNeutralText) }
    static var neutralBg:        Color { Color(hex: palette.colorNeutralBg) }
    
    //white , light green
    static var primaryText:      Color { Color(hex: palette.color1Text) }
    static var primaryBg:        Color { Color(hex: palette.color1Bg) }
    
    // white , light Orange
    static var secondaryText:    Color { Color(hex: palette.color2Text) }
    static var secondaryBg:      Color { Color(hex: palette.color2Bg) }
}
