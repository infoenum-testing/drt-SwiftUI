//
//  OfflineStrings.swift
//  DRTScanner
//
//  Created by IE15 on 18/07/25.
//


import Foundation

struct OfflineStrings: Codable {
    let success: String
    let uploaded: String
    let blockedTicket: String
    let download: String
    let invalidBarcode: String
    let uploading: String

    enum CodingKeys: String, CodingKey {
        case success
        case uploaded
        case blockedTicket = "blocked-ticket"
        case download
        case invalidBarcode = "invalid-barcode"
        case uploading
    }
}
