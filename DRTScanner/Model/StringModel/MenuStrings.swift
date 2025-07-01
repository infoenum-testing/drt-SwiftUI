//
//  MenuStrings.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct MenuStrings: Codable {

	let stopScanning: String
	let goOnline: String
	let goOffline: String
	let about: String
	let website: String

	private enum CodingKeys: String, CodingKey {
		case stopScanning = "stop-scanning"
		case goOnline = "go-online"
		case goOffline = "go-offline"
		case about = "about"
		case website = "website"
	}

}
