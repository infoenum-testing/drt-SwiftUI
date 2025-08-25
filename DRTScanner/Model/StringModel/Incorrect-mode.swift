//
//  Incorrect-mode.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct IncorrectMode: Codable {
    let merch: String
    let tickets: String
    let incorrectMode: String
    private enum CodingKeys: String, CodingKey {
        case merch
        case tickets
        case incorrectMode = "incorrect-mode"
    }
}

