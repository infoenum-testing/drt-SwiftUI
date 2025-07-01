//
//  Search-results.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct SearchResults: Codable {

	let totalResults: String
	let cc: String
	let order: String
	let counts: String
	let phoneNumber: String

	private enum CodingKeys: String, CodingKey {
		case totalResults = "total-results"
		case cc = "cc"
		case order = "order"
		case counts = "counts"
		case phoneNumber = "phone-number"
	}

}
