//
//  MenuStrings.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct MenuStrings: Codable {
    let about: String
    let change: String
    let goOffline: String
    let goOnline: String
    let logOut: String
    let scanMerch: String
    let scanTickets: String
    let scanningStats: String
    let stopScanning: String
    let website: String
    
    private enum CodingKeys: String, CodingKey {
        case about
        case change
        case goOffline = "go-offline"
        case goOnline = "go-online"
        case logOut = "log-out"
        case scanMerch = "scan-merch"
        case scanTickets = "scan-tickets"
        case scanningStats = "scanning-stats"
        case stopScanning = "stop-scanning"
        case website
    }
}
