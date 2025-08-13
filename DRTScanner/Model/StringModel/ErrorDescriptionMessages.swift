//
//  ErrorDescriptionMessages.swift
//  DRTScanner
//
//  Created by IE15 on 23/07/25.
//
import Foundation

struct ErrorDescriptionMessages: Codable {
    let reachServer: String
    let badResponse: String
    let findServer: String
    let connectSecurely: String
    let connect: String
    let connectionOffline: String
    
    private enum CodingKeys: String, CodingKey {
        case reachServer = "reach-server"
        case badResponse = "bad-response"
        case findServer = "find-server"
        case connectSecurely = "connect-securely"
        case connect
        case connectionOffline = "connection-offline"
    }
}
