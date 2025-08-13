//
//  OfflineStrings.swift
//  DRTScanner
//
//  Created by IE15 on 18/07/25.
//


import Foundation

struct OfflineStrings: Codable {
    let download: String
    let success: String
    let uploading: String
    let downloading: String
    let uploaded: String
    let invalidBarcode: String
    let blockedTicket: String
    let uploadFailed: String
    
    private enum CodingKeys: String, CodingKey {
        case download
        case success
        case uploading
        case downloading
        case uploaded
        case invalidBarcode = "invalid-barcode"
        case blockedTicket = "blocked-ticket"
        case uploadFailed = "upload-failed"
    }
}
