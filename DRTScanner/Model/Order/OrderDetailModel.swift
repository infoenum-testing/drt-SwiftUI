//
//  OrderDetailModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/02/25.
//

import Foundation

struct OrderDetailModel: Codable {
    
    let valid: Bool?
    let buyerName: String?
    let cc: String?
    var oid: Int?
    let seats: [SeatModel]?
    
    init(valid: Bool? = nil, buyerName: String? = nil, cc: String? = nil, oid: Int? = nil, seats: [SeatModel]? = nil) {
           self.valid = valid
           self.buyerName = buyerName
           self.cc = cc
           self.oid = oid
           self.seats = seats
       }
    
    private enum CodingKeys: String, CodingKey {
        case valid = "valid"
        case buyerName = "buyerName"
        case cc = "cc"
        case seats = "seats"
        case oid = "oid"
    }
}
