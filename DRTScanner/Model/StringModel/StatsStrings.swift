//
//  Stats.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 02/07/25.
//


import Foundation

struct StatsStrings: Codable {
    let scanned: String
    let totalSeats: String
    let scanningStats: String
    let totalScannedDevice: String
    let totalScannableSeats: String
    let ticketsScannedByDevice: String
    let scannable: String
    let totalScannedSeats: String
    
    enum CodingKeys: String, CodingKey {
        case scanned = "scanned"
        case totalSeats = "total-seats"
        case scanningStats = "scanning-stats"
        case totalScannedDevice = "total-scanned-device"
        case totalScannableSeats = "total-scannable-seats"
        case ticketsScannedByDevice = "tickets-scanned-by-device"
        case scannable = "scannable"
        case totalScannedSeats = "total-scanned-seats"
    }
}
