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

extension Date {
    static func todayAtTime(_ timeString: String) -> Date? {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let timeOnlyDate = timeFormatter.date(from: timeString) else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timeOnlyDate)
        var todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        todayComponents.hour = timeComponents.hour
        todayComponents.minute = timeComponents.minute
        
        return calendar.date(from: todayComponents)
    }
}
