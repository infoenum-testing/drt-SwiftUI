//
//  MerchandiseOrder.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 07/03/25.
//


import SwiftUI

struct MerchandiseOrder: Codable, Identifiable {
    let id = UUID()
    var orderId: Int?
    let name: String
    let variantName: String
    let qrCode: [String]?
    var qty: Int
    var qtyScanned: Int
    let iconSrc: String
    var date_Scanned: String
    
    enum CodingKeys: String, CodingKey {
        case orderId, name, variantName, qrCode, qty
        case qtyScanned = "qty_scanned"
        case iconSrc = "icon_src"
        case date_Scanned
    }
    static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone.current
            return formatter
        }()
}
