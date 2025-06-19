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
        case buyerName = "buyerName"
        case goldenTicketText = "goldenTicketText"
        case displayMessage = "displayMessage"
        case isGoldenTicket = "isGoldenTicket"
        case tsScanned = "tsScanned"
        case dateScanned = "dateScanned"
    }
}
