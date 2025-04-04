//
//  SettingsViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    @AppStorage("kShouldPlayBeep") var shouldPlayBeep: Bool = false
    @AppStorage("kShouldPlayHaptic") var shouldPlayHaptic: Bool = false
    @AppStorage("kDeviceSleepTimeout") var deviceSleepTimeout: Int = 0
    @AppStorage("kPauseScanTimeout") var pauseScanTimeout: Int = 0
    @AppStorage("kDuplicateScanSuppression") var duplicateScanSuppression: Int = 0
    @AppStorage("kShowScanStats") var showScanStats: Bool = false
    @AppStorage("kAutoEnableFlashTimeout") var autoEnableFlashTimeout: Bool = false
    
    let secArray = (0...59).map { "\($0) secs" }
    let minArray = (0...10).map { "\($0) mins" }
    
    @Published var deviceSleepTimeoutText: String = "00:00 mins"
    @Published var pauseScanTimeoutText: String = "0 sec"
    @Published var duplicateScanSuppressionText: String = "0 sec"
    
    let deviceSleepOptions = (0...10).map { "\($0):00 mins" }
    let pauseScanOptions = (0...29).map { "\($0) sec" }
    let duplicateScanOptions = stride(from: 0, through: 30, by: 5).map { "\($0) sec" }
    
    init() {
        updateTextValues()
    }
    
    func getTimeOptions(for index: Int) -> [String] {
        switch index {
        case 2: return deviceSleepOptions
        case 3: return pauseScanOptions
        case 4: return duplicateScanOptions
        default: return []
        }
    }
    
    func saveTime(_ timeIndex: Int, for index: Int) {
        switch index {
        case 2:
            deviceSleepTimeout = timeIndex
        case 3:
            pauseScanTimeout = timeIndex
        case 4:
            duplicateScanSuppression = timeIndex * 5
        default: break
        }
        updateTextValues()
    }
    
    private func updateTextValues() {
        deviceSleepTimeoutText = "\(deviceSleepTimeout):00 mins"
        pauseScanTimeoutText = "\(pauseScanTimeout) sec"
        duplicateScanSuppressionText = "\(duplicateScanSuppression) sec"
        objectWillChange.send()
    }
}
