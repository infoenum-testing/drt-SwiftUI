//
//  OrderDetailModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/02/25.
//

import Foundation

struct OrderDetailModel: Codable {
    
    let valid: Bool
    let buyerName: String
    let cc: String
    let seats: [SeatModel]
    
    private enum CodingKeys: String, CodingKey {
        case valid = "valid"
        case buyerName = "buyer_name"
        case cc = "cc"
        case seats = "seats"
    }
}
