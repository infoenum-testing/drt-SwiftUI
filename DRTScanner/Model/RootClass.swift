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
}

struct SkinModel: Codable {

    let color2Bg: String?
    let colorNeutralBg: String?
    let colorNeutralText: String?
    let logoHref: String?
    let color2Text: String?
    let color1Bg: String?
    let backgroundHref: String?
    let color1Text: String?

}

struct StatsModel: Codable {

    let totalSeats: Int?
    let seatsScannable: Int?
    let seatsScannedTotal: Int?
    let seatsScannedByDevice: Int?

}
