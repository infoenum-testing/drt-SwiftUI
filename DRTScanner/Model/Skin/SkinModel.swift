//
//  SkinModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/05/25.
//

import Foundation

struct SkinModel: Codable {

    let colorValid: String
    let colorNeutralText: String
    let colorNeutralBg: String
    let color1Text: String
    let backgroundHref: String
    let colorInvalid: String
    let colorPrevious: String
    let color2Bg: String
    let color1Bg: String
    let color2Text: String
    let logoHref: String
    let colorButtonBg: String
    let colorButtonText: String
    let colorGoldenTicket: String
    let colorGrayText: String
    private enum CodingKeys: String, CodingKey {
        case colorValid = "colorValid"
        case colorNeutralText = "colorNeutralText"
        case colorNeutralBg = "colorNeutralBg"
        case color1Text = "color1Text"
        case backgroundHref = "backgroundHref"
        case colorInvalid = "colorInvalid"
        case colorPrevious = "colorPrevious"
        case color2Bg = "color2Bg"
        case color1Bg = "color1Bg"
        case color2Text = "color2Text"
        case logoHref = "logoHref"
        case colorButtonBg = "colorButtonBg"
        case colorButtonText = "colorButtonText"
        case colorGoldenTicket = "colorGoldenTicket"
        case colorGrayText = "colorGrayText"
    }
}

extension SkinModel {
    init?(skin: Skin) {
        guard
            let valid = skin.color_Valid,
            let neutralText = skin.color_neutral_text,
            let neutralBg = skin.color_neutral_bg,
            let oneText = skin.color_1_text,
            let oneBg = skin.color_1_bg,
            let twoText = skin.color_2_text,
            let twoBg = skin.color_2_bg,
            let invalid = skin.color_Invalid,
            let prev = skin.color_Previous,
            let bgHref = skin.background_href,
            let logo = skin.logo_href,
            let colorButtonBg = skin.colorButtonBg,
            let colorButtonText = skin.colorButtonText,
            let colorGoldenTicket = skin.colorGoldenTicket,
            let colorGrayText = skin.colorGrayText
        else {
            return nil
        }

        self.colorValid = valid
        self.colorNeutralText = neutralText
        self.colorNeutralBg = neutralBg
        self.color1Text = oneText
        self.color1Bg = oneBg
        self.color2Text = twoText
        self.color2Bg = twoBg
        self.colorInvalid = invalid
        self.colorPrevious = prev
        self.backgroundHref = bgHref
        self.logoHref = logo
        self.colorButtonBg = colorButtonBg
        self.colorButtonText = colorButtonText
        self.colorGoldenTicket = colorGoldenTicket
        self.colorGrayText = colorGrayText
    }
}
