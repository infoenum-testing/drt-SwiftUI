//
//  CameraScannerView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 04/04/25.
//

import SwiftUI

struct CameraScannerView: UIViewControllerRepresentable, Equatable {
    var onScan: (String) -> Void
    var onControllerCreated: ((ScannerViewController) -> Void)?
    let controller: ScannerViewController
    @Binding var isScanning: Bool
    @Binding var isSideMenuPresented: Bool
    
    static func == (lhs: CameraScannerView, rhs: CameraScannerView) -> Bool {
        return lhs.controller == rhs.controller
    }
    
    init(
        isScanning: Binding<Bool>,
        isSideMenuPresented: Binding<Bool>,
        controller: ScannerViewController,
        onScan: @escaping (String) -> Void,
        onControllerCreated: ((ScannerViewController) -> Void)? = nil
    ) {
        self._isScanning = isScanning
        self._isSideMenuPresented = isSideMenuPresented
        self.controller = controller
        self.onScan = onScan
        self.onControllerCreated = onControllerCreated
    }

    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.onScan = onScan
        controller.isScanningBinding = $isScanning
        onControllerCreated?(controller)
        return controller
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        if isScanning {
            guard isSideMenuPresented == false else { return }
            uiViewController.startScanning()
            print("my camera session start ✅")
        } else {
            uiViewController.stopScanning()
            print("my camera session stop ❌")
        }
    }

    static func dismantleUIViewController(_ uiViewController: ScannerViewController, coordinator: ()) {
        uiViewController.isStopSessionByME = true
        if uiViewController.captureSession?.isRunning ?? false {
            uiViewController.stopScanning()
        }
    }
}
