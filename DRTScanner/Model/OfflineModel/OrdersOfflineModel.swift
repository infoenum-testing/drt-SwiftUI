//
//  OrdersOfflineModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/05/25.
//

import Foundation

struct OrdersOfflineModel: Codable {

    let oid: Int?
    let buyerName: String?
    let cc: String?
    let phone: String?

    private enum CodingKeys: String, CodingKey {
        case oid = "0"
        case buyerName = "1"
        case cc = "2"
        case phone = "3"
    }

}
