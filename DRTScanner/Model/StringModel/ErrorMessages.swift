//
//  ErrorMessages.swift
//  DRTScanner
//
//  Created by IE15 on 23/07/25.
//
import Foundation

struct ErrorMessages: Codable {
    let timedout: String
    let badServerResponse: String
    let findServer: String
    let connect: String
    let connectSecurely: String
    let offline: String
    let invalidShowCode: String
    let error: String
    
    private enum CodingKeys: String, CodingKey {
        case timedout
        case badServerResponse = "bad-server-response"
        case findServer = "find-server"
        case connect
        case connectSecurely = "connect-securely"
        case offline
        case invalidShowCode = "invalidShowCode"
        case error
    }
}
