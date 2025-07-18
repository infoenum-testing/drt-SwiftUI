//
//  Stats.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 02/07/25.
//


import Foundation

struct StatsStrings: Codable {
    let scannable: String
    let totalScannedSeats: String
    let scanned: String
    let totalScannedDevice: String
    let totalScannableSeats: String
    let totalSeats: String
    
    private enum CodingKeys: String, CodingKey {
        case scannable = "scannable"
        case totalScannedSeats = "total-scanned-seats"
        case scanned = "scanned"
        case totalScannedDevice = "total-scanned-device"
        case totalScannableSeats = "total-scannable-seats"
        case totalSeats = "total-seats"
    }
    
}
