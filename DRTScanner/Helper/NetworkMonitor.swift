//
//  NetworkMonitor.swift
//  DRTScanner
//
//  Created by IE15 on 19/07/25.
//


import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    private(set) var isConnected: Bool = false

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
    
    /// Returns true if network is available
    func isNetworkAvailable() -> Bool {
        return isConnected
    }
}
