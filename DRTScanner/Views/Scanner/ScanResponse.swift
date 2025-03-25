//
//  ScanResponse.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 21/03/25.
//

import SwiftUI

struct ScanResponse: Codable {
    let valid: Bool
    let message: String?
    let seat: Int?
    let section: String?
    let buyerName: String?
    let tsScanned: String?
    let dateScanned: String?
    let handicap: Bool?
    let isGoldenTicket: Bool?
    let goldenTicketText: String?
    let stats: ScanStats?
}

struct ScanStats: Codable {
    let seatsScannedByDevice: Int
    let seatsScannedTotal: Int
    let seatsScannable: Int
}
