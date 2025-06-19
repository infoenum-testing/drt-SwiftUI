//
//  SkinModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/05/25.
//

import Foundation

struct SkinModel: Codable {
    
    let colorNeutralText: String
    let colorNeutralBg: String
    let color1Text: String
    let backgroundHref: String
    let color2Bg: String
    let color1Bg: String
    let color2Text: String
    let logoHref: String
    
    private enum CodingKeys: String, CodingKey {
        case colorNeutralText = "colorNeutralText"
        case colorNeutralBg = "colorNeutralBg"
        case color1Text = "color1Text"
        case backgroundHref = "backgroundHref"
        case color2Bg = "color2Bg"
        case color1Bg = "color1Bg"
        case color2Text = "color2Text"
        case logoHref = "logoHref"
    }
    
}
