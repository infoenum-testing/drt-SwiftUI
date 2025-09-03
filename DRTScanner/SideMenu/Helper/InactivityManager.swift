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

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isAsleep: Bool = false

    private init() {
        observeAppLifecycle()
        observeTimeoutChanges()
    }

    func resetTimer() {
        timer?.invalidate()

        DispatchQueue.main.async {
            self.isAsleep = false
            UIApplication.shared.isIdleTimerDisabled = true
        }

        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(30 * 60), repeats: false) { [weak self] _ in
            self?.enterSleepMode()
        }
    }

    func wakeUp() {
        resetTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        isAsleep = false
    }

    private func enterSleepMode() {
        DispatchQueue.main.async {
            self.isAsleep = true
            UIApplication.shared.isIdleTimerDisabled = false
        }
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

    private func observeTimeoutChanges() {
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                self?.resetTimer()
            }
            .store(in: &cancellables)
    }

    @objc private func appWillResignActive() {
        stop()
    }

    @objc private func appDidBecomeActive() {
        resetTimer()
    }
}
