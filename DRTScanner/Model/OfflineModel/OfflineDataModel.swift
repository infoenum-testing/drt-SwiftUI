//
//  OfflineDataModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 24/02/25.
//

import Foundation

struct OfflineDataModel: Codable {
    
    let valid: Bool?
    let message: String?
    let showId: Int?
    let studioId: Int?
    let showDt: String?
    let dbCode: String?
    let orders: [OrdersOfflineModel]?
    
    private enum CodingKeys: String, CodingKey {
        case valid = "valid"
        case message = "message"
        case showId = "show_id"
        case studioId = "studio_id"
        case showDt = "showDt"
        case dbCode = "db_code"
        case orders = "orders"
    }
}
