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
        case phoneFormat = "phoneFormat"
        case showId = "showId"
        case showDt = "showDt"
        case stats
        case valid
        case studioId = "studioId"
        case skin
        case isUserLoggedIn
    }
}
