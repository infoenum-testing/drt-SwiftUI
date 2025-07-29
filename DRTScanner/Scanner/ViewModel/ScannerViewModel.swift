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
    
    private var audioPlayer: AVAudioPlayer?
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
    
    /// Plays feedback for a scan event, such as a beep sound and/or haptic feedback, depending on the provided flags.
     func playScanFeedback(scannerResult: ScannerResult, haptic: Bool) {
         let shouldPlayBeep = UserDefaults.standard.bool(forKey: "kShouldPlayBeep")
         if !shouldPlayBeep {
             return
         }
        if scannerResult == .valid {
            if let soundURL = Bundle.main.url(forResource: "scan", withExtension: "wav") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()
                } catch {
                    print("Error playing beep.mp3: \(error.localizedDescription)")
                }
            } else {
                print("beep.mp3 not found in bundle")
            }
        } else if scannerResult == .invalid || scannerResult == .previouslyScanned {
            if let soundURL = Bundle.main.url(forResource: "fail", withExtension: "wav") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()
                } catch {
                    print("Error playing beep.mp3: \(error.localizedDescription)")
                }
            } else {
                print("beep.mp3 not found in bundle")
            }
        }
        if haptic {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) // Haptic vibration
        }
    }
}
