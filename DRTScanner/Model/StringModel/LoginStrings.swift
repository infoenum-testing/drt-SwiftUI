//
//  Login.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct LoginStrings: Codable {

	let enterShowCode: String
    let showCode: String

	private enum CodingKeys: String, CodingKey {
		case enterShowCode = "enter-show-code"
        case showCode = "show-code"
	}

}
