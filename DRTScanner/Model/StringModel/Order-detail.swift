//
//  Order-detail.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct OrderDetail: Codable {

	let notYetScanned: String
	let row: String
	let seat: String
	let section: String
	let invalidTicket: String
	let invalidProduct: String
	let previouslyscanned: String

	private enum CodingKeys: String, CodingKey {
		case notYetScanned = "not-yet-scanned"
		case row = "row"
		case seat = "seat"
		case section = "section"
		case invalidTicket = "invalid-ticket"
		case invalidProduct = "invalid-product"
		case previouslyscanned = "previously scanned"
	}
    

}
