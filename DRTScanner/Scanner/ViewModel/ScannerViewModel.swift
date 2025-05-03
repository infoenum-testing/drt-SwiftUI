//
//  ScannerViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 20/03/25.
//

import SwiftUI
import AVFoundation
class ScannerViewModel: ObservableObject {
    @Published var showAlert = false
    @Published var isValidCode = false
    @Published var alertMessage = ""
    
    @Published var shouldResetScanner = false
    
    func triggerReset() {
        shouldResetScanner.toggle()
    }
    
    func disableFlash() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }

        var didLock = false

        do {
            try device.lockForConfiguration()
            didLock = true
            if device.isTorchActive {
                device.torchMode = .off
                print("🔦 Torch turned off.")
            }
        } catch {
            print("⚠️ Could not lock device for configuration: \(error)")
        }

        if didLock {
            device.unlockForConfiguration()
        }
    }
}
