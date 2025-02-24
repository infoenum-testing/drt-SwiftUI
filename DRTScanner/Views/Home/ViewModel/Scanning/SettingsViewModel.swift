//
//  SettingsViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var settingArray: [String] = [
        "Beep/buzz", "Haptic Feedback",
        "Device Sleep timeout",
         "Pause scan timeout",
        "Duplicate Scan suppression",
        "Scan stats on scan screen",
        "Auto enable flash timeout"
    ]
    
    @Published var secArray: [String] = []
    @Published var minArray: [String] = ["0 mins", "1 mins", "2 mins", "3 mins", "4 mins", "5 mins", "6 mins", "7 mins", "8 mins", "9 mins", "10 mins"]
    
    init() {
        for i in 0...59 {
            secArray.append("\(i) secs")
        }
    }
    
    func saveTime(_ time: Int, forKey key: String) {
        // Save time logic (assuming you're using UserDefaults or some persistent storage)
    }
    
    func getTime(forKey key: String) -> Int {
        // Get time logic (use UserDefaults or your storage to fetch values)
        return 0
    }
    
    func getBool(forKey key: String) -> Bool {
        // Retrieve bool from settings (UserDefaults or your storage)
        return false
    }
    
    func setBool(_ value: Bool, forKey key: String) {
        // Save bool in settings (UserDefaults or your storage)
    }
}
