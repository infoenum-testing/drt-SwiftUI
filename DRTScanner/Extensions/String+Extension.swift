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
    
    
    static func getScanLabel(from scanDate: Date) -> String {
        let now = Date()
        let diffSeconds = Int(now.timeIntervalSince(scanDate))
        let diffMinutes = diffSeconds / 60
        let diffHours = diffMinutes / 60
        let diffDays = diffHours / 24


        let labelTemplate =  StringManager.shared.strings.orderDetail.previouslyScanned

        switch diffMinutes {
        case ..<2:
            let lable =  String(format: labelTemplate, "")
            return "\(lable) \n \(StringManager.shared.strings.orderDetail.justNow)"
        case 2..<60:
            let timeLabel = String(format: StringManager.shared.strings.orderDetail.minsAgo, "\(diffMinutes)")
            let lable = String(format: labelTemplate, "")
            return "\(lable)\n \(timeLabel)"
        case 60..<1440:
            let hourAgoString = diffHours == 1 ? StringManager.shared.strings.orderDetail.hourAgo : StringManager.shared.strings.orderDetail.hoursAgo
            let timeLabel = String(format: hourAgoString, "\(diffHours)")
            let lable = String(format: labelTemplate, "")
            return "\(lable)\n\(timeLabel)"
        case 1440..<2880:
            let lable = String(format: labelTemplate, "")
            return "\(lable)\n\(StringManager.shared.strings.orderDetail.yesterday)"

        default:
            let timeLabel = String(format: StringManager.shared.strings.orderDetail.daysAgo, "\(diffDays)")
            let lable = String(format: labelTemplate, "")
            return "\(lable)\n\(timeLabel)"
        }
    }
}
