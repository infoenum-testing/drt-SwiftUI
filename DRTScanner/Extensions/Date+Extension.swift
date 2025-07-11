//
//  Date.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 05/02/25.
//

import Foundation

extension Date {
    static func getTime(from timestampString: String) -> Date? {
        guard let timestamp = TimeInterval(timestampString) else { return nil }
        return Date(timeIntervalSince1970: timestamp / 1000)
    }
}

extension Date {
    func formatToTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
}
