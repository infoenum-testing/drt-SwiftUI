//
//  ErrorDescriptionMessages.swift
//  DRTScanner
//
//  Created by IE15 on 23/07/25.
//
import Foundation

struct ErrorDescriptionMessages: Codable {
    let badResponse: String
    let findServer: String
    let connectSecurely: String
    let reachServer: String
    let connect: String
    let connectionOffline: String

    enum CodingKeys: String, CodingKey {
        case badResponse = "bad-response"
        case findServer = "find-server"
        case connectSecurely = "connect-securely"
        case reachServer = "reach-server"
        case connect = "connect"
        case connectionOffline = "connection-offline"
    }
}
