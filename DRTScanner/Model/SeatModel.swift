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
    let qr: Qr
    let tsScanned: String?

    enum CodingKeys: String, CodingKey {
        case section = "section"
        case row = "row"
        case seat = "seat"
        case qr = "qr"
        case tsScanned = "ts_scanned"
    }
}

struct Qr: Codable {
    let code: String?
    let valid: Bool?
    
    enum CodingKeys: String, CodingKey {
        case code = "qr_code"
        case valid = "is_valid"
    }
}
