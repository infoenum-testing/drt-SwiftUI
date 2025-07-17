//
//  Dialog-go-offline.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct DialogGoOffline: Codable {

	let cancel: String
	let typeName: String
	let preparing: String
	let downloading: String
	let title: String
	let continueField: String
	let badInput: String
	let description: String

	private enum CodingKeys: String, CodingKey {
		case cancel = "cancel"
		case typeName = "type-name"
		case preparing = "preparing"
		case downloading = "downloading"
		case title = "title"
		case continueField = "continue"
		case badInput = "bad-input"
		case description = "description"
	}
}
