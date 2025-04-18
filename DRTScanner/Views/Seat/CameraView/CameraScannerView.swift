//
//  CameraScannerView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 04/04/25.
//

import SwiftUI

struct CameraScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void
    var onControllerCreated: ((ScannerViewController) -> Void)?
    @Binding var isScanning: Bool

    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.onScan = onScan
        controller.isScanningBinding = $isScanning
        onControllerCreated?(controller)
        return controller
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        if isScanning {
            uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }

    static func dismantleUIViewController(_ uiViewController: ScannerViewController, coordinator: ()) {
        uiViewController.captureSession?.stopRunning()
    }
}
