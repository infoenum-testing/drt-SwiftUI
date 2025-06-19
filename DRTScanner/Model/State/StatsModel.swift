//
//  StatsModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/05/25.
//

import Foundation

struct StatsModel: Codable {

    var totalSeats: Int?
    var seatsScannable: Int?
    var seatsScannedTotal: Int?
    var seatsScannedByDevice: Int?

    enum CodingKeys: String, CodingKey {
           case totalSeats = "totalSeats"
           case seatsScannable = "seatsScannable"
           case seatsScannedTotal = "seatsScannedTotal"
           case seatsScannedByDevice = "seatsScannedByDevice"
       }
}
