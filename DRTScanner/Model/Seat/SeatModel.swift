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
    var tsScanned: Int?
    var scannedTime: Date? {
            get {
                guard let tsScanned = tsScanned else { return nil }
                return Date(timeIntervalSince1970: TimeInterval(tsScanned))
            }
            set {
                if let newValue = newValue {
                    tsScanned = Int(newValue.timeIntervalSince1970)
                } else {
                    tsScanned = nil
                }
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
}
