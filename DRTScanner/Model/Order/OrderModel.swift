//
//  OrderModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.
//

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

    init(
        buyerName: String?,
        cc: String?,
        phone: String?,
        orderId: Int?,
        valid: Bool?,
        goldenTicketText: String?,
        isGoldenTicket: Bool?,
        message: String?,
        seats: [SeatModel]?,
        merch: [Merchandise]?
    ) {
        self.buyerName = buyerName
        self.cc = cc
        self.phone = phone
        self.orderId = orderId
        self.valid = valid
        self.goldenTicketText = goldenTicketText
        self.isGoldenTicket = isGoldenTicket
        self.message = message
        self.seats = seats
        self.merch = merch
    }
    
    private enum CodingKeys: String, CodingKey {
        case buyerName
        case buyer_name
        case cc
        case phone
        case orderId
        case order_id
        case goldenTicketText = "golden_ticket_text"
        case isGoldenTicket = "is_golden_ticket"
        case valid
        case seats
        case merch
        case message
    }

    // MARK: - Decoding (supporting multiple keys)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.buyerName = try container.decodeIfPresent(String.self, forKey: .buyer_name)
            ?? container.decodeIfPresent(String.self, forKey: .buyerName)
        
        self.orderId = try container.decodeIfPresent(Int.self, forKey: .order_id)
            ?? container.decodeIfPresent(Int.self, forKey: .orderId)

        self.cc = try container.decodeIfPresent(String.self, forKey: .cc)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.valid = try container.decodeIfPresent(Bool.self, forKey: .valid)
        self.goldenTicketText = try container.decodeIfPresent(String.self, forKey: .goldenTicketText)
        self.isGoldenTicket = try container.decodeIfPresent(Bool.self, forKey: .isGoldenTicket)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.seats = try container.decodeIfPresent([SeatModel].self, forKey: .seats)
        self.merch = try container.decodeIfPresent([Merchandise].self, forKey: .merch)
    }

    // MARK: - Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(buyerName, forKey: .buyerName)
        try container.encodeIfPresent(cc, forKey: .cc)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(orderId, forKey: .orderId)
        try container.encodeIfPresent(valid, forKey: .valid)
        try container.encodeIfPresent(goldenTicketText, forKey: .goldenTicketText)
        try container.encodeIfPresent(isGoldenTicket, forKey: .isGoldenTicket)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(seats, forKey: .seats)
        try container.encodeIfPresent(merch, forKey: .merch)
    }
}
