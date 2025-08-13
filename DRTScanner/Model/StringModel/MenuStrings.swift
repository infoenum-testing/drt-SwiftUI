//
//  MenuStrings.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct MenuStrings: Codable {
    let goOffline: String
    let goOnline: String
    let about: String
    let stopScanning: String
    let website: String
    let change: String
    let selected: String
    let scanMerch: String
    let scanTickets: String
    let logOut: String
    let scanningStats: String
    let settings: String
    
    private enum CodingKeys: String, CodingKey {
        case goOffline = "go-offline"
        case goOnline = "go-online"
        case about
        case stopScanning = "stop-scanning"
        case website
        case change
        case selected
        case scanMerch = "scan-merch"
        case scanTickets = "scan-tickets"
        case logOut = "log-out"
        case scanningStats = "scanning-stats"
        case settings
    }
}
