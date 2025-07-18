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
    @AppStorage("kDeviceSleepTimeout") var deviceSleepTimeout: Int = 0
    @AppStorage("kPauseScanTimeout") var pauseScanTimeout: Int = 0
    
    // Scan behavior settings related to duplicate suppression
    @AppStorage("kDuplicateScanSuppression") var duplicateScanSuppression: Int = 10
    @AppStorage("kShowScanStats") var showScanStats: Bool = false
    @AppStorage("kAutoEnableFlashTimeout") var autoEnableFlashTimeout: Bool = false
    
    // MARK: - Time Options Arrays
    
    // Arrays for time options displayed in the UI
    let secArray = (0...59).map { "\($0) secs" }
    let minArray = (0...10).map { "\($0) mins" }
    
    // Published variables for text formatting of time options (displayed to the user)
    @Published var deviceSleepTimeoutText: String = "00:00 mins"
    @Published var pauseScanTimeoutText: String = "0 sec"
    @Published var duplicateScanSuppressionText: String = "0 sec"
    @Published var selectedLangText: String =  UserDefaults.standard.string(forKey: "selectedLang") ?? LangCode.current()
    
    // MARK: - Predefined Time Option Strings
    
    // Predefined time options for each setting
    let deviceSleepOptions = (0...10).map { "\($0):00 mins" }
    let pauseScanOptions = (0...29).map { "\($0) sec" }
    let duplicateScanOptions = stride(from: 0, through: 30, by: 5).map { "\($0) sec" }
    let languages = [StringManager.shared.allLangStrings?.enUS.lang ?? "en_US", StringManager.shared.allLangStrings?.frCA.lang ?? "fr_CA",StringManager.shared.allLangStrings?.esUS.lang ?? "es_US"]
    
    init() {
        updateTextValues()
    }
    
    /// Returns the available time options for a specific setting based on its index.
    func getTimeOptions(for index: Int) -> [String] {
        switch index {
        case 2: return deviceSleepOptions
        case 3: return pauseScanOptions
        case 4: return duplicateScanOptions
        case 5: return languages
        default: return []
        }
    }
    
    /// Saves the selected time value for a specific setting based on its index.
    func saveTime(_ timeIndex: Int, for index: Int) {
        switch index {
        case 2:
            deviceSleepTimeout = timeIndex
        case 3:
            pauseScanTimeout = timeIndex
        case 4:
            duplicateScanSuppression = timeIndex * 5 // Set duplicate scan suppression (in 5 seconds)
        case 5:
            UserDefaults.standard.set(languages[timeIndex],forKey: "selectedLang")
            selectedLangText = languages[timeIndex]
            StringManager.shared.updateLang(for: languages[timeIndex])
        default: break
        }
        // Update the displayed text values based on saved settings
        updateTextValues()
    }
    
    /// Updates the text values that display time-related settings to the user.
    private func updateTextValues() {
        deviceSleepTimeoutText = deviceSleepTimeout == 0 ? "Off" : "\(deviceSleepTimeout):00 mins"
        pauseScanTimeoutText = pauseScanTimeout == 0 ? "Off" : "\(pauseScanTimeout) sec"
        duplicateScanSuppressionText = duplicateScanSuppression == 0 ? "Off" : "\(duplicateScanSuppression) sec"
        
        // Notify listeners that the object will change (for updates in the view)
        objectWillChange.send()
    }
}
