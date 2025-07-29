//
//  Settings.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 02/07/25.
//


import Foundation

struct Settings: Codable {
    
    let scanStats: String
    let sleepTimer: String
    let haptics: String
    let flashTimeout: String
    let sound: String
    let settings: String
    let off: String
    let mins: String
    let sec: String
    let save: String
    let timer: String
    let duplicate: String
    let language: String
    
    private enum CodingKeys: String, CodingKey {
        case scanStats = "scan-stats"
        case sleepTimer = "sleep-timer"
        case save = "save"
        case haptics = "haptics"
        case flashTimeout = "flash-timeout"
        case sound = "sound"
        case settings = "settings"
        case timer = "timer"
        case duplicate = "duplicate"
        case language = "change-language"
        case off = "off"
        case mins = "mins"
        case sec = "sec"
    }
}
