//
//  SkinModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/05/25.
//

import Foundation

struct SkinModel: Codable {
    let color2Bg: String
    let colorNeutralBg: String
    let colorNeutralText: String
    let logoHref: String
    let color2Text: String
    let color1Bg: String
    let backgroundHref: String
    let color1Text: String
    
    private enum CodingKeys: String, CodingKey {
        case color2Bg = "color_2_bg"
        case colorNeutralBg = "color_neutral_bg"
        case colorNeutralText = "color_neutral_text"
        case logoHref = "logo_href"
        case color2Text = "color_2_text"
        case color1Bg = "color_1_bg"
        case backgroundHref = "background_href"
        case color1Text = "color_1_text"
    }
    
}
