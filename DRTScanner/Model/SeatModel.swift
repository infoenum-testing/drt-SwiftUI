//
//  SeatModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 10/02/25.
//


import Foundation

struct SeatModel: Codable {
    let section: String
    let row: String
    let seat: String
    let barcode: String?
    let qrCode: String?
    let qr: Qr?
    var tsScanned: String?
    var scannedTime: Date? {
            get {
                guard let tsScanned = tsScanned else { return nil }
                return SeatModel.dateFormatter.date(from: tsScanned)
            }
            set {
                tsScanned = newValue != nil ? SeatModel.dateFormatter.string(from: newValue!) : nil
            }
        }

    enum CodingKeys: String, CodingKey {
        case section = "section"
        case row = "row"
        case seat = "seat"
        case qr = "qr"
        case tsScanned = "ts_scanned"
        case barcode
        case qrCode
    }
    
    static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone.current
            return formatter
        }()
}

struct Qr: Codable {
    let code: String?
    let valid: Bool?
    
    enum CodingKeys: String, CodingKey {
        case code = "qr_code"
        case valid = "is_valid"
    }
}
