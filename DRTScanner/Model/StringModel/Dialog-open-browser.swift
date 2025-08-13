//
//  Dialog-open-browser.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct DialogOpenBrowser: Codable {
    let continueField: String
    let cancel: String
    let description: String
    
    private enum CodingKeys: String, CodingKey {
        case continueField = "continue"
        case cancel
        case description
    }
}
