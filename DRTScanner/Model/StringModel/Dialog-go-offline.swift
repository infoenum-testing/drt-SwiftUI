//
//  Dialog-go-offline.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct DialogGoOffline: Codable {
    let title: String
    let description: String
    let typeName: String
    let continueField: String
    let cancel: String
    let badInput: String
    let preparing: String
    let downloading: String
    let goOnlineFailed: String
    
    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case typeName = "type-name"
        case continueField = "continue"
        case cancel
        case badInput = "bad-input"
        case preparing
        case downloading
        case goOnlineFailed
    }
}
