//
//  ScannerViewController.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 04/04/25.
//

import AVFoundation
import UIKit
import Vision
import SwiftUI

class ScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var onScan: ((String) -> Void)?
    var isScanningBinding: Binding<Bool>?
    var flashControlHandler: ((Bool) -> Void)?
    private var hasCheckedPermissions = false
    var isStopSessionByME: Bool = false
    @AppStorage("kAutoEnableFlashTimeout") private var autoEnableFlashTimeout: Bool = false

    private var scheduledFlashWorkItem: DispatchWorkItem?
    private var isScanningEnabled = true
    private(set) var isScanning = false

    private var boundingBoxLayer = CAShapeLayer()
    private var flashAutoOffTimer: Timer?
    private var isFlashOn = false
    private var scanningWatchdogTimer: Timer?
    
    private var lastScannedValue: String?
    
    private var lastProcessedFrameTime: Date = .distantPast
    private let frameProcessingInterval: TimeInterval = 0.2 // throttle frames
    private let scanCooldown: TimeInterval = 1.0 // prevent duplicate scans within 1s
    private var lastScanTime: Date = .distantPast
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleAutoFlash), name: .enableAutoFlash, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !hasCheckedPermissions {
            hasCheckedPermissions = true
            checkCameraPermission()
        }
        checkCameraSessionRunning()
    }

    // Cleans up observers when the controller is deallocated
    deinit {
        scanningWatchdogTimer?.invalidate()
        flashAutoOffTimer?.invalidate()
        scheduledFlashWorkItem?.cancel()
        NotificationCenter.default.removeObserver(self)
        print("🗑️ ScannerViewController deinitialized")
    }
    
    func checkCameraSessionRunning() {
        // Always reset the timer
        scanningWatchdogTimer?.invalidate()

        scanningWatchdogTimer = Timer.scheduledTimer(withTimeInterval: 30*60, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.isStopSessionByME {
                self.scanningWatchdogTimer?.invalidate()
                self.scanningWatchdogTimer = nil
                return
            }

            // Check capture session state
            let isRunning = self.captureSession?.isRunning ?? false

            if !isRunning {
                print("🔄 Restarting capture session (watchdog)")
                DispatchQueue.global(qos: .userInitiated).async {
                    self.captureSession?.startRunning()
                }
            }

            // Refresh preview layer to avoid freezes
            DispatchQueue.main.async {
                self.previewLayer?.frame = self.view.bounds
                self.previewLayer?.setNeedsDisplay()
                self.previewLayer?.connection?.isEnabled = true
            }
        }
    }

    // MARK: - Camera Permission Handling

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupCamera()
                    } else {
                        self.showCameraPermissionAlert()
                    }
                }
            }
        case .denied, .restricted:
            showCameraPermissionAlert()
        @unknown default:
            showCameraPermissionAlert()
        }
    }

    // Shows an alert if camera permission is denied
    private func showCameraPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access Needed",
            message: "Please enable camera access in Settings to scan QR codes.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: StringManager.shared.strings.dialogLogout.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: StringManager.shared.strings.settings.settings, style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })

        present(alert, animated: true)
    }

    // MARK: - Camera Setup

    var onCameraReady: (() -> Void)?
    func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .hd1280x720

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("🚫 No video capture device found")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if session.canAddInput(input) { session.addInput(input) }
        } catch {
            print("❌ Error setting up camera input: \(error)")
            return
        }

        let output = AVCaptureVideoDataOutput()
        let outputQueue = DispatchQueue(label: "CameraSampleBufferQueue")
        output.setSampleBufferDelegate(self, queue: outputQueue)
        if session.canAddOutput(output) { session.addOutput(output) }

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }

        boundingBoxLayer.strokeColor = UIColor.red.cgColor
        boundingBoxLayer.lineWidth = 2
        boundingBoxLayer.fillColor = UIColor.clear.cgColor
        boundingBoxLayer.isHidden = true
        view.layer.addSublayer(boundingBoxLayer)

        captureSession = session
        DispatchQueue.global(qos: .userInitiated).async {
            if !(self.captureSession?.isRunning ?? false) { session.startRunning() }
            DispatchQueue.main.async {
                self.isScanning = true
                self.onCameraReady?()
            }
        }
    }

    // MARK: - Flash Control

    @objc private func handleAutoFlash() {
        turnFlashOn()
    }

    func turnFlashOn() {
        guard !isFlashOn, let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        DispatchQueue.main.async {
            do {
                try device.lockForConfiguration()
                try device.setTorchModeOn(level: 1.0)
                device.unlockForConfiguration()
                self.isFlashOn = true
                self.startFlashAutoOffTimer()
            } catch { print("⚠️ Flash On Error: \(error)") }
        }
    }

    func turnFlashOff() {
        guard isFlashOn, let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        DispatchQueue.main.async {
            do {
                try device.lockForConfiguration()
                device.torchMode = .off
                device.unlockForConfiguration()
                self.isFlashOn = false
                self.flashAutoOffTimer?.invalidate()
                self.flashAutoOffTimer = nil
            } catch { print("⚠️ Flash Off Error: \(error)") }
        }
    }

    private func startFlashAutoOffTimer() {
        flashAutoOffTimer?.invalidate()
        flashAutoOffTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.turnFlashOff()
        }
    }

    // MARK: - Scanning Control

    func startScanning() {
        guard !isScanning, captureSession?.isRunning == false else { return }
        isScanning = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            if !(self.captureSession?.isRunning ?? false) { self.captureSession?.startRunning() }
            print("▶️ Capture session started")
            if self.autoEnableFlashTimeout, AVCaptureDevice.default(for: .video)?.hasTorch == true {
                self.scheduledFlashWorkItem?.cancel()
                let workItem = DispatchWorkItem { [weak self] in self?.turnFlashOn() }
                self.scheduledFlashWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
            }
        }
    }

    // Stops the scanning session
    func stopScanning() {
          if captureSession?.isRunning == true {
              captureSession?.stopRunning()
              isScanning = false
              turnFlashOff()
              print("🛑 Capture session stopped")
          }
          scheduledFlashWorkItem?.cancel()
          scheduledFlashWorkItem = nil
      }

    func enableScanning(_ enable: Bool) { isScanningEnabled = enable }

    // MARK: - Bounding Box Drawing

    private func drawBoundingBox(for observation: VNBarcodeObservation) {
        guard let previewLayer = self.previewLayer else { return }

        var rect = observation.boundingBox
        rect.origin.y = 1 - rect.origin.y - rect.size.height

        let convertedRect = previewLayer.layerRectConverted(fromMetadataOutputRect: rect)

        let path = UIBezierPath(rect: convertedRect)

        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = boundingBoxLayer.path
        animation.toValue = path.cgPath
        animation.duration = 0.15
        boundingBoxLayer.add(animation, forKey: "pathAnimation")

        boundingBoxLayer.path = path.cgPath
        boundingBoxLayer.isHidden = false
    }

    // MARK: - Barcode Detection

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let now = Date()
        guard now.timeIntervalSince(lastProcessedFrameTime) > frameProcessingInterval else { return }
        lastProcessedFrameTime = now

        guard isScanningBinding?.wrappedValue ?? true,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectBarcodesRequest { request, error in
            guard error == nil,
                  let results = request.results as? [VNBarcodeObservation],
                  let bestResult = results.first,
                  let payload = bestResult.payloadStringValue else {
                DispatchQueue.main.async {
                    // no barcode → hide bounding box
                    self.boundingBoxLayer.isHidden = true
                }
                return
            }

            DispatchQueue.main.async {
                guard let previewLayer = self.previewLayer else { return }
                var rect = bestResult.boundingBox
                rect.origin.y = 1 - rect.origin.y - rect.size.height
                let convertedRect = previewLayer.layerRectConverted(fromMetadataOutputRect: rect)

                if self.view.bounds.contains(convertedRect) {
                    self.drawBoundingBox(for: bestResult)
                    if self.autoEnableFlashTimeout { self.turnFlashOn() }

                    if payload != self.lastScannedValue || now.timeIntervalSince(self.lastScanTime) > self.scanCooldown {
                        self.lastScannedValue = payload
                        self.lastScanTime = now
                        self.onScan?(payload)
                    } else {
                        // no barcode → hide bounding box
                        self.boundingBoxLayer.isHidden = true
                    }
                }
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}

extension Notification.Name {
    static let enableAutoFlash = Notification.Name("enableAutoFlash")
}
