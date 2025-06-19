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
               guard let tsScanned = tsScanned,
                     let timestamp = Double(tsScanned) else { return nil }
               return Date(timeIntervalSince1970: timestamp / 1000) // assuming ms
           }
           set {
               if let newValue = newValue {
                   // Convert Date to milliseconds string
                   let milliseconds = Int(newValue.timeIntervalSince1970 * 1000)
                   tsScanned = String(milliseconds)
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
        case tsScanned = "tsScanned"
        case barcode
        case qrCode
    }
}
