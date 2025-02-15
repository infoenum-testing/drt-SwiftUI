//
//  Date.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 05/02/25.
//

import Foundation

//extension Date {
//    static func getTime(from timestampString: String) -> String? {
//        guard let timestamp = TimeInterval(timestampString) else { return nil }
//        let date = Date(timeIntervalSince1970: timestamp / 1000)
//        
//        let formatter = DateFormatter()
//        formatter.amSymbol = "am"
//        formatter.pmSymbol = "pm"
//        formatter.dateFormat = "hh:mm a"
//        
//        return formatter.string(from: date)
//    }
//}

extension Date {
    static func getTime(from timestampString: String) -> Date? {
        guard let timestamp = TimeInterval(timestampString) else { return nil }
        return Date(timeIntervalSince1970: timestamp / 1000)
    }
}
