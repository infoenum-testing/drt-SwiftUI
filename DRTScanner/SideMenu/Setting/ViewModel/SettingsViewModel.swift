//
//  SettingsViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    // Boolean flags for preferences regarding sound and haptic feedback
    @AppStorage("kShouldPlayBeep") var shouldPlayBeep: Bool = false
    @AppStorage("kShouldPlayHaptic") var shouldPlayHaptic: Bool = false
    
    // Timeout settings for device sleep and scan pause
    @AppStorage("kPauseScanTimeout") var pauseScanTimeout: Int = 0
    
    // Scan behavior settings related to duplicate suppression
    @AppStorage("kDuplicateScanSuppression") var duplicateScanSuppression: Int = 10
    @AppStorage("kShowScanStats") var showScanStats: Bool = false
    @AppStorage("kAutoEnableFlashTimeout") var autoEnableFlashTimeout: Bool = false
    
    // MARK: - Time Options Arrays
    
    // Arrays for time options displayed in the UI
    let mins = StringManager.shared.strings.settings.mins
    let sec = StringManager.shared.strings.settings.sec
    let off = StringManager.shared.strings.settings.off
    
    // Published variables for text formatting of time options (displayed to the user)
    @Published var deviceSleepTimeoutText: String = "00:00 \(StringManager.shared.strings.settings.mins)"
    @Published var pauseScanTimeoutText: String = "0 \(StringManager.shared.strings.settings.sec)"
    @Published var duplicateScanSuppressionText: String = "0 \(StringManager.shared.strings.settings.sec)"
    @Published var selectedLangText: String =  UserDefaults.standard.string(forKey: "selectedLang") ?? StringManager.shared.currentLang()
    
    // MARK: - Predefined Time Option Strings
    // Predefined time options for each setting
    lazy var deviceSleepOptions = (0...10).map { "\($0):00 \(mins)" }
    lazy var pauseScanOptions = ["0", "10", "20", "30"].map { "\($0) \(sec)" }
    lazy var  duplicateScanOptions = stride(from: 0, through: 30, by: 5).map { "\($0) \(sec)" }
    var languages: [String] {
         StringManager.allLanguages().map { $0.name }
     }
    
    init() {
        updateTextValues()
    }
    
    /// Returns the available time options for a specific setting based on its index.
    func getTimeOptions(for index: Int) -> [String] {
        switch index {
        case 2: return pauseScanOptions
        case 3: return duplicateScanOptions
        case 4: return languages
        default: return []
        }
    }
    
    /// Saves the selected time value for a specific setting based on its index.
    func saveTime(_ timeIndex: Int, for index: Int) {
        switch index {
        case 2:
            pauseScanTimeout = timeIndex * 10
        case 3:
            duplicateScanSuppression = timeIndex * 5 // Set duplicate scan suppression (in 5 seconds)
        case 4:
            UserDefaults.standard.set(languages[timeIndex],forKey: "selectedLang")
            selectedLangText = languages[timeIndex]
            StringManager.shared.updateLang(for: languages[timeIndex])
            reloadStrings()
        default: break
        }
        // Update the displayed text values based on saved settings
        updateTextValues()
    }
    
    /// Updates the text values that display time-related settings to the user.
    private func updateTextValues() {
        let sec = StringManager.shared.strings.settings.sec
        let off = StringManager.shared.strings.settings.off
        pauseScanTimeoutText = pauseScanTimeout == 0 ? off : "\(pauseScanTimeout) \(sec)"
        duplicateScanSuppressionText = duplicateScanSuppression == 0 ? off : "\(duplicateScanSuppression) \(sec)"
        
        // Notify listeners that the object will change (for updates in the view)
        objectWillChange.send()
    }
    
    private func reloadStrings() {
        let mins = StringManager.shared.strings.settings.mins
        let sec = StringManager.shared.strings.settings.sec
        
        pauseScanTimeoutText = "0 \(sec)"
        duplicateScanSuppressionText =  "0 \(sec)"
        deviceSleepOptions = (0...10).map { "\($0):00 \(mins)" }
        pauseScanOptions = ["0", "10", "20", "30"].map { "\($0) \(sec)" }
        duplicateScanOptions = stride(from: 0, through: 30, by: 5).map { "\($0) \(sec)" }
        
    }
}
