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
    var seats: [SeatModel]?
    let success: Bool?
    let message: String?
    
    private enum CodingKeys: String, CodingKey {
        case buyerName = "buyer_name"
        case cc = "cc"
        case phone = "phone"
        case orderId = "order_id"
        case studioId = "studio_id"
        case success = "success"
        case message = "message"
    }
}

struct OrdersNewApi: Codable {
    let buyerName: String?
    let cc: String?
    let phone: String?
    let orderId: Int?
    let valid: Bool?
    let message: String?
    let seats: [SeatModel]?
    let merch: [Merchandise]?

    private enum CodingKeys: String, CodingKey {
        case buyerName = "buyer_name"
        case cc = "cc"
        case phone = "phone"
        case orderId = "order_id"
        case valid
        case seats
        case merch
        case message
    }
}

struct Merchandise: Codable {
    
    let name: String?
    let variantName: String?
    let qty: Int?
    let icon: String?
    let message: String?
    let qr: QrMerchandise?
    
    var tsScanned: Int64?
    
    var scannedTime: Date? {
            get {
                guard let tsScanned = tsScanned else { return nil }
                return Date(timeIntervalSince1970: TimeInterval(tsScanned / 1000))
            }
            set {
                tsScanned = newValue != nil ? Int64(newValue!.timeIntervalSince1970 * 1000) : nil
            }
        }
    
    // Updated date formatter to handle timestamps in number format
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    // Custom decoding for `ts_scanned`
    enum CodingKeys: String, CodingKey {
        case name
        case variantName = "variant_name"
        case qty
        case icon
        case qr
        case tsScanned = "ts_scanned"
        case message
    }
    
    init(name: String? = nil, variantName: String? = nil, qty: Int? = nil, icon: String? = nil, message: String? = nil, qr: QrMerchandise? = nil, tsScanned: Int64? = nil) {
            self.name = name
            self.variantName = variantName
            self.qty = qty
            self.icon = icon
            self.message = message
            self.qr = qr
            self.tsScanned = tsScanned
        }
}

struct QrMerchandise: Codable {
    
    let merch: [String]
    
    private enum CodingKeys: String, CodingKey {
        case merch = "merch"
    }
    
}
