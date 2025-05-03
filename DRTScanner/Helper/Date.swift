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
