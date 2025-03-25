//
//  DeviceManager.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 05/03/25.
//

import Foundation
import UIKit

class DeviceManager {
    static let shared = DeviceManager()
    
    private let deviceNameKey = "savedDeviceName"
    
    private init() {}
    
    func getDeviceName() -> String {
        if let savedName = UserDefaults.standard.string(forKey: deviceNameKey) {
            return savedName
        }
        
        let newDeviceName = generateDeviceName()
        UserDefaults.standard.set(newDeviceName, forKey: deviceNameKey)
        return newDeviceName
    }
    
    private func generateDeviceName() -> String {
        let device = UIDevice.current
        let modelName = device.model.replacingOccurrences(of: " ", with: "-")
        let systemVersion = device.systemVersion
        let uniqueID = UUID().uuidString.prefix(6)
        
        return "\(modelName)-\(systemVersion)-\(uniqueID)"
    }
    
    func deleteDeviceName() {
        UserDefaults.standard.removeObject(forKey: deviceNameKey)
    }
}
