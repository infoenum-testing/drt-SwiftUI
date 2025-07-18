//
//  Home.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct HomeStrings: Codable {
    let ok: String
	let phoneNumber: String
	let orderNumber: String
	let seat: String
	let lookUpBy: String
	let serviceName: String
	let name: String
	let creditCard: String

	private enum CodingKeys: String, CodingKey {
        case ok =  "ok"
		case phoneNumber = "phone-number"
		case orderNumber = "order-number"
		case seat = "seat"
		case lookUpBy = "look-up-by"
		case serviceName = "service-name"
		case name = "name"
		case creditCard = "credit-card"
	}

}
