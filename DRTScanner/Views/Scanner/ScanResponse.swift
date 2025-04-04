//
//  ScanResponse.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 21/03/25.
//

import SwiftUI

struct ScanResponse: Codable {
    let valid: Bool
    let cc: String?
    let section: String?
    let handicap: Bool?
    let buyerName: String?
    let oid: Int?
    let message: String?
    let goldenTicketText: String?
    let displayMessage: String?
    let seat: Int?
    let row: String?
    let isGoldenTicket: Bool?
    let stats: ScanStats?
    let tsScanned: String?
    let dateScanned: String?

    enum CodingKeys: String, CodingKey {
        case valid, cc, section, handicap, oid, message, seat, row, stats
        case buyerName = "buyer_name"
        case goldenTicketText = "golden_ticket_text"
        case displayMessage = "display_message"
        case isGoldenTicket = "is_golden_ticket"
        case tsScanned = "ts_scanned"
        case dateScanned = "date_scanned"
    }
}

struct ScanStats: Codable {
    let seatsScannedByDevice: Int
    let seatsScannedTotal: Int
    let seatsScannable: Int

    enum CodingKeys: String, CodingKey {
        case seatsScannedByDevice = "seats_scanned_by_device"
        case seatsScannedTotal = "seats_scanned_total"
        case seatsScannable = "seats_scannable"
    }
}
