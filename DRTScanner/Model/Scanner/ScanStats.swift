//
//  ScanStats.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/05/25.
//

import Foundation

struct ScanStats: Codable {
    let seatsScannedByDevice: Int
    let seatsScannedTotal: Int
    let seatsScannable: Int

    enum CodingKeys: String, CodingKey {
        case seatsScannedByDevice = "seatsScannedByDevice"
        case seatsScannedTotal = "seatsScannedTotal"
        case seatsScannable = "seatsScannable"
    }
}
