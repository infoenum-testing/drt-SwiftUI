//
//  DRTDynamicString.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 17/02/25.
//

import SwiftUI

class DRTDynamicString {
    
    class func managedOfflineStatsAddSeat(isAdd: Bool) {
        
        let statsOld = DRTDatabaseManager.shared.allRecordsSortByAttribute(nil, fromTable: String(describing: Stats.self))
        
        if !statsOld.isEmpty {
            guard let statsCurrent = statsOld.first as? Stats else { return }
            
            var totalScannedSeats = Int("\(statsCurrent.seats_scanned_total ?? 0)") ?? 0
            var totalScannedByDevice = Int("\(statsCurrent.seats_scanned_by_device ?? 0)") ?? 0
            let totalSeats = Int("\(statsCurrent.total_seats ?? 0)") ?? 0
            let totalSeatsScannable = Int("\(statsCurrent.seats_scannable ?? 0)") ?? 0
            
            if isAdd {
                totalScannedSeats += 1
                totalScannedByDevice += 1
            } else {
                totalScannedSeats = max(0, totalScannedSeats - 1)
                totalScannedByDevice = max(0, totalScannedByDevice - 1)
            }
            
            // Deleting all records from Stats table
            DRTDatabaseManager.shared.deleteAllTableRecord(String(describing: Stats.self))
            
            let statsDict: [String: Any] = [
                "total_seats": totalSeats,
                "seats_scannable": totalSeatsScannable,
                "seats_scanned_by_device": totalScannedByDevice,
                "seats_scanned_total": totalScannedSeats
            ]
            
            // Inserting the updated stats record
            DRTDatabaseManager.shared.insertStatsRecordInStatsTable(statsDict)
        }
    }
    
}
