//
//  ErrorMessages.swift
//  DRTScanner
//
//  Created by IE15 on 23/07/25.
//
import Foundation

struct ErrorMessages: Codable {
    let badServerResponse: String
    let connect: String
    let connectSecurely: String
    let invalidShowCode: String
    let offline: String
    let timedout: String
    let findServer: String
    let error: String

    enum CodingKeys: String, CodingKey {
        case badServerResponse = "bad-server-response"
        case connect = "connect"
        case connectSecurely = "connect-securely"
        case invalidShowCode = "invalidShowCode"
        case offline = "offline"
        case timedout = "timedout"
        case findServer = "find-server"
        case error = "error"
    }
}
