//
//  RootClass.swift
//  Created on February 11, 2025
//
import Foundation

struct DRTUser: Codable {

	let phoneFormat: String?
	let showId: String?
	let showDt: String?
	let stats: StatsModel?
	let valid: Bool?
	let studioId: Int?
	let skin: SkinModel?
    let isUserLoggedIn: Bool?
    
    var showCode: String? {
        return showId
    }
    
    enum CodingKeys: String, CodingKey {
           case phoneFormat = "phone_format"
           case showId = "show_id"
           case showDt = "show_dt"
           case stats
           case valid
           case studioId = "studio_id"
           case skin
           case isUserLoggedIn
       }
}

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

struct StatsModel: Codable {

    var totalSeats: Int?
    var seatsScannable: Int?
    var seatsScannedTotal: Int?
    var seatsScannedByDevice: Int?

    enum CodingKeys: String, CodingKey {
           case totalSeats = "total_seats"
           case seatsScannable = "seats_scannable"
           case seatsScannedTotal = "seats_scanned_total"
           case seatsScannedByDevice = "seats_scanned_by_device"
       }
}
