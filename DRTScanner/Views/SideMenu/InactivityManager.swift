//
//  InactivityManager.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 09/04/25.
//

import Foundation
import SwiftUI
import Combine

class InactivityManager: ObservableObject {
    static let shared = InactivityManager()
    
    @AppStorage("kDeviceSleepTimeout") private var timeoutMinutes: Int = 1
    private var timer: Timer?
    
    @Published var isAsleep: Bool = false

    private init() {
        observeAppLifecycle()
    }

    func start() {
        resetTimer()
    }

    func resetTimer() {
        timer?.invalidate()
        DispatchQueue.main.async {
               self.isAsleep = false
           }

        UIApplication.shared.isIdleTimerDisabled = true

        let timeout: TimeInterval? = timeoutMinutes > 0 ? TimeInterval(timeoutMinutes * 60) : nil
        
        if let timeout = timeout {
            UIApplication.shared.isIdleTimerDisabled = true
            timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
                self?.enterSleepMode()
            }
        } else {
            UIApplication.shared.isIdleTimerDisabled = false
            timer = nil
        }
    }

    func wakeUp() {
        resetTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        UIApplication.shared.isIdleTimerDisabled = false
        isAsleep = false
    }


    private func enterSleepMode() {
        isAsleep = true
        UIApplication.shared.isIdleTimerDisabled = false
    }

    private func observeAppLifecycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func appWillResignActive() {
        stop()
    }

    @objc private func appDidBecomeActive() {
        start()
    }
}
