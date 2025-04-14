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

    @AppStorage("kAutoEnableFlashTimeout") private var autoEnableFlashTimeout: Bool = false

    private var scheduledFlashWorkItem: DispatchWorkItem?
    private var isScanningEnabled = true
    private var didJustScan = false
    private(set) var isScanning = false

    private var boundingBoxLayer = CAShapeLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        NotificationCenter.default.addObserver(self, selector: #selector(handleAutoFlash), name: .enableAutoFlash, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("🗑️ ScannerViewController deinitialized")
    }

    // MARK: - Camera Setup

    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .hd1280x720

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("🚫 No video capture device found")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            print("❌ Error setting up camera input: \(error)")
            return
        }

        let output = AVCaptureVideoDataOutput()
        let outputQueue = DispatchQueue(label: "CameraSampleBufferQueue")
        output.setSampleBufferDelegate(self, queue: outputQueue)

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }

        // Setup red bounding box layer
        boundingBoxLayer.strokeColor = UIColor.red.cgColor
        boundingBoxLayer.lineWidth = 2
        boundingBoxLayer.fillColor = UIColor.clear.cgColor
        boundingBoxLayer.isHidden = true
        view.layer.addSublayer(boundingBoxLayer)

        captureSession = session
        DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
                DispatchQueue.main.async {
                    self.isScanning = true
                    print("📷 Capture session started")
                }
            }
    }

    // MARK: - Flash Control

    @objc private func handleAutoFlash() {
        print("⚡ Auto flash triggered")
        turnFlashOn()
    }

    func turnFlashOn() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        DispatchQueue.main.async {
            do {
                try device.lockForConfiguration()
                try device.setTorchModeOn(level: 1.0)
                device.unlockForConfiguration()
                print("💡 Flash turned ON")
            } catch {
                print("⚠️ Flash On Error: \(error)")
            }
        }
    }

    func turnFlashOff() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        DispatchQueue.main.async {
            do {
                try device.lockForConfiguration()
                device.torchMode = .off
                device.unlockForConfiguration()
                print("💡 Flash turned OFF")
            } catch {
                print("⚠️ Flash Off Error: \(error)")
            }
        }
    }

    // MARK: - Scanning Control

    func startScanning() {
        guard !isScanning, captureSession?.isRunning == false else { return }
        isScanning = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            self.captureSession?.startRunning()
            print("▶️ Capture session started")

            if self.autoEnableFlashTimeout,
               AVCaptureDevice.default(for: .video)?.hasTorch == true {

                self.scheduledFlashWorkItem?.cancel()

                let workItem = DispatchWorkItem { [weak self] in
                    self?.turnFlashOn()
                }

                self.scheduledFlashWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
            }
        }
    }

    func stopScanning() {
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
            print("🛑 Capture session stopped")
            isScanning = false
            turnFlashOff()
        }

        scheduledFlashWorkItem?.cancel()
        scheduledFlashWorkItem = nil
    }

    func enableScanning(_ enable: Bool) {
        isScanningEnabled = enable
    }

    // MARK: - Bounding Box Drawing

    private func drawBoundingBox(for observation: VNBarcodeObservation) {
        guard let previewLayer = self.previewLayer else { return }

        let boundingBox = observation.boundingBox
        let convertedRect = previewLayer.layerRectConverted(fromMetadataOutputRect: boundingBox)

        let path = UIBezierPath(rect: convertedRect)
        boundingBoxLayer.path = path.cgPath
        boundingBoxLayer.isHidden = false
    }

    // MARK: - Barcode Detection

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isScanningBinding?.wrappedValue ?? true else { return }
        guard !didJustScan else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectBarcodesRequest { request, error in
            guard error == nil,
                  let results = request.results as? [VNBarcodeObservation],
                  let bestResult = results.first,
                  let payload = bestResult.payloadStringValue else { return }

            DispatchQueue.main.async {
                self.drawBoundingBox(for: bestResult)

                self.didJustScan = true
                self.isScanningBinding?.wrappedValue = false
                self.onScan?(payload)

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.didJustScan = false
                    self.isScanningBinding?.wrappedValue = true
                    self.boundingBoxLayer.isHidden = true
                }
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}



import Foundation

extension Notification.Name {
    static let enableAutoFlash = Notification.Name("enableAutoFlash")
}
