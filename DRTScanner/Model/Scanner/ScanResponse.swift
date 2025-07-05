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
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.valid = try container.decode(Bool.self, forKey: .valid)
        self.cc = try container.decodeIfPresent(String.self, forKey: .cc)
        self.section = try container.decodeIfPresent(String.self, forKey: .section)
        self.handicap = try container.decodeIfPresent(Bool.self, forKey: .handicap)
        self.oid = try container.decodeIfPresent(Int.self, forKey: .oid)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.seat = try container.decodeIfPresent(Int.self, forKey: .seat)
        self.row = try container.decodeIfPresent(String.self, forKey: .row)
        self.stats = try container.decodeIfPresent(ScanStats.self, forKey: .stats)
        self.buyerName = try container.decodeIfPresent(String.self, forKey: .buyerName)
        self.goldenTicketText = try container.decodeIfPresent(String.self, forKey: .goldenTicketText)
        self.displayMessage = try container.decodeIfPresent(String.self, forKey: .displayMessage)
        self.isGoldenTicket = try container.decodeIfPresent(Bool.self, forKey: .isGoldenTicket)
        if let tsScanned = try? container.decodeIfPresent(String.self, forKey: .tsScanned) {
            self.tsScanned = tsScanned
        } else if let tsScanned = try? container.decodeIfPresent(Double.self, forKey: .tsScanned) {
            self.tsScanned = String(tsScanned)
        } else {
            self.tsScanned = ""
        }
        self.dateScanned = try container.decodeIfPresent(String.self, forKey: .dateScanned)
    }
}
