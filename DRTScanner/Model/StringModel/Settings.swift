//
//  Settings.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 02/07/25.
//


import Foundation

struct Settings: Codable {
    
    let settings: String
    let sound: String
    let haptics: String
    let sleepTimer: String
    let sleepTimerInstructions: String
    let timer: String
    let timerInstructions: String
    let duplicate: String
    let duplicateInstructions: String
    let scanStats: String
    let flashTimeout: String
    let save: String
    let changeLanguage: String
    let sec: String
    let mins: String
    let off: String
    let mode: String
    let offline: String
    let online: String
    
    private enum CodingKeys: String, CodingKey {
        case settings
        case sound
        case haptics
        case sleepTimer = "sleep-timer"
        case sleepTimerInstructions = "sleep-timer-instructions"
        case timer
        case timerInstructions = "timer-instructions"
        case duplicate
        case duplicateInstructions = "duplicate-instructions"
        case scanStats = "scan-stats"
        case flashTimeout = "flash-timeout"
        case save
        case changeLanguage = "change-language"
        case sec
        case mins
        case off
        case mode
        case offline
        case online
    }
}
