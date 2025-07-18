//
//  Seat.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct SeatStrings: Codable {

	let seat: String
	let row: String
	let section: String
	let continueField: String
    let lookUpSeat: String

	private enum CodingKeys: String, CodingKey {
		case seat = "seat"
		case row = "row"
		case section = "section"
		case continueField = "continue"
        case lookUpSeat = "look-up-seat"
	}

}
