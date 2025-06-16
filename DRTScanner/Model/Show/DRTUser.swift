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
        case showDt = "showDt"
        case stats
        case valid
        case studioId = "studio_id"
        case skin
        case isUserLoggedIn
    }
}
