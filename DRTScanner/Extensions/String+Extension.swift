//
//  String+Extension.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 10/07/25.
//
import Foundation

extension String {
    public func formatToDate() -> String {
        guard let timestampMillis = TimeInterval(self) else {
            return self
        }
        
        let date = Date(timeIntervalSince1970: timestampMillis / 1000)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    func toDateFromMillisecondsTimestamp() -> Date? {
           // Try converting to Double first
           guard let timestampDouble = Double(self) else {
               return nil
           }
           
           // Convert milliseconds to seconds
           let date = Date(timeIntervalSince1970: timestampDouble / 1000)
           return date
       }
}
