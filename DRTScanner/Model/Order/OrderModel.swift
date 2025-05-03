//
//  OrderModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.
//

import Foundation

struct OrdersNewApi: Codable {
    let buyerName: String?
    let cc: String?
    let phone: String?
    let orderId: Int?
    let valid: Bool?
    let goldenTicketText: String?
    let isGoldenTicket: Bool?
    let message: String?
    let seats: [SeatModel]?
    let merch: [Merchandise]?
    
    private enum CodingKeys: String, CodingKey {
        case buyerName = "buyer_name"
        case cc = "cc"
        case phone = "phone"
        case orderId = "order_id"
        case goldenTicketText = "golden_ticket_text"
        case isGoldenTicket = "is_golden_ticket"
        case valid
        case seats
        case merch
        case message
    }
}
