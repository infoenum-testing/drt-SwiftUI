//
//  Dialog-logout.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct DialogLogout: Codable {

	let whenOfflineDescription: String
	let continueField: String
	let cancel: String
	let whenOfflineTitle: String
	let confirm: String
	let areYouSure: String

	private enum CodingKeys: String, CodingKey {
		case whenOfflineDescription = "when-offline-description"
		case continueField = "continue"
		case cancel = "cancel"
		case whenOfflineTitle = "when-offline-title"
		case confirm = "confirm"
		case areYouSure = "are-you-sure"
	}

}
