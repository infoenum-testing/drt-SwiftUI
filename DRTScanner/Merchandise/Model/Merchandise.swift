//
//  Merchandise.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/05/25.
//

import SwiftUI

struct Merchandise: Codable {
    
    let name: String?
    let variantName: String?
    let qty: Int?
    let orderId: Int?
    let icon: String?
    let message: String?
    let qr: QrMerchandise?
    let qtyScanned: Int?
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
        case variantName = "variantName"
        case qty
        case icon
        case qr
        case tsScanned = "ts_scanned"
        case message
        case orderId = "orderId"
        case qtyScanned = "qtyScanned"
    }
    
    init(name: String? = nil, variantName: String? = nil, qty: Int? = nil, icon: String? = nil, message: String? = nil, qr: QrMerchandise? = nil, tsScanned: Int64? = nil, orderId: Int? = nil, qtyScanned: Int? = nil) {
            self.name = name
            self.variantName = variantName
            self.qty = qty
            self.icon = icon
            self.message = message
            self.qr = qr
            self.tsScanned = tsScanned
            self.orderId = orderId
            self.qtyScanned = qtyScanned
        }
}
