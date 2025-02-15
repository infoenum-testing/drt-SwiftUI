//
//  OrderModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.
//

import Foundation

struct OrderModel: Codable {

    let valid: Bool?
    let numOrders: Int?
    let orders: [Orders]?
    
    private enum CodingKeys: String, CodingKey {
        case valid = "valid"
        case numOrders = "num_orders"
        case orders = "orders"
    }
}

struct Orders: Codable {
    
    let buyerName: String?
    let cc: String?
    let phone: String?
    let orderId: Int?
    let studioId: Int?
    
    private enum CodingKeys: String, CodingKey {
        case buyerName = "buyer_name"
        case cc = "cc"
        case phone = "phone"
        case orderId = "order_id"
        case studioId = "studio_id"
    }
}
