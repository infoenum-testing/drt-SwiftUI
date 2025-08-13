//
//  Stats.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 02/07/25.
//


import Foundation

struct StatsStrings: Codable {
    let scannable: String
    let scanned: String
    let totalScannedDevice: String
    let totalScannedSeats: String
    let totalScannableSeats: String
    let totalSeats: String
    let scanningStats: String
    let ticketsScannedByDevice: String
    
    enum CodingKeys: String, CodingKey {
        case scannable
        case scanned
        case totalScannedDevice = "total-scanned-device"
        case totalScannedSeats = "total-scanned-seats"
        case totalScannableSeats = "total-scannable-seats"
        case totalSeats = "total-seats"
        case scanningStats = "scanning-stats"
        case ticketsScannedByDevice = "tickets-scanned-by-device"
    }
}
