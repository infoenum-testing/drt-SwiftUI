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

    init(section: String, row: String, seat: String, barcode: String? = nil, qrCode: String? = nil, qr: Qr? = nil, tsScanned: String? = nil) {
        self.section = section
        self.row = row
        self.seat = seat
        self.barcode = barcode
        self.qrCode = qrCode
        self.qr = qr
        self.tsScanned = tsScanned
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.section = try container.decode(String.self, forKey: .section)
        self.row = try container.decode(String.self, forKey: .row)
        self.seat = try container.decode(String.self, forKey: .seat)
        self.qr = try container.decodeIfPresent(Qr.self, forKey: .qr)
        if let tsScanned = try? container.decodeIfPresent(String.self, forKey: .tsScanned) {
            self.tsScanned = tsScanned
        } else if let tsScanned = try? container.decodeIfPresent(Double.self, forKey: .tsScanned) {
            self.tsScanned = String(tsScanned)
        } else {
            self.tsScanned = ""
        }
        self.barcode = try container.decodeIfPresent(String.self, forKey: .barcode)
        self.qrCode = try container.decodeIfPresent(String.self, forKey: .qrCode)
    }
}
