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
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.onScan = onScan
        onControllerCreated?(controller)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
    
    static func dismantleUIViewController(_ uiViewController: ScannerViewController, coordinator: ()) {
        uiViewController.captureSession?.stopRunning()
    }
}
