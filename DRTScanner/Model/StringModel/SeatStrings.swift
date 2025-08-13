//
//  Seat.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation


struct SeatStrings: Codable {
    let seat: String
    let section: String
    let row: String
    let continueField: String
    let lookUpSeat: String
    let scan: String
    
    private enum CodingKeys: String, CodingKey {
        case seat
        case section
        case row
        case continueField = "continue"
        case lookUpSeat = "look-up-seat"
        case scan
    }
}
