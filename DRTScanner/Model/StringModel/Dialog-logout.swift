//
//  Dialog-logout.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation


struct DialogLogout: Codable {
    let confirm: String
    let areYouSure: String
    let continueField: String
    let cancel: String
    let whenOfflineTitle: String
    let whenOfflineDescription: String
    
    private enum CodingKeys: String, CodingKey {
        case confirm
        case areYouSure = "are-you-sure"
        case continueField = "continue"
        case cancel
        case whenOfflineTitle = "when-offline-title"
        case whenOfflineDescription = "when-offline-description"
    }
}
