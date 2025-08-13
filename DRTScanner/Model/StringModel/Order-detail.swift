//
//  Order-detail.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct OrderDetail: Codable {
    let section: String
    let row: String
    let seat: String
    let previouslyScanned: String
    let invalidTicket: String
    let invalidProduct: String
    let notYetScanned: String
    let scanned: String
    let justNow: String
    let yesterday: String
    let minsAgo: String
    let hourAgo: String
    let hoursAgo: String
    let daysAgo: String
    
    private enum CodingKeys: String, CodingKey {
        case section
        case row
        case seat
        case previouslyScanned = "previously scanned"
        case invalidTicket = "invalid-ticket"
        case invalidProduct = "invalid-product"
        case notYetScanned = "not-yet-scanned"
        case scanned
        case justNow = "just-now"
        case yesterday
        case minsAgo = "mins-ago"
        case hourAgo = "hour-ago"
        case hoursAgo = "hours-ago"
        case daysAgo = "days-ago"
    }
}
