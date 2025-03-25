//
//  ScannerView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/02/25.
//

import SwiftUI
import AVFoundation
import Vision
import IQAPIClient
import CoreData

struct ScannerView: View {
    @Binding var seat: SeatModel?
    @State private var scannedCode: String?
    @State private var scanResult: String?
    @State private var isScanning = true
    @State private var flashLight: AVCaptureDevice?
    @State private var scanViewHeight: CGFloat = UIScreen.main.bounds.height * 3 / 8.5
    @State private var linePosition: CGFloat
    private let lineSpeed: CGFloat = 70.0
    @State private var timer: Timer?
    @State private var isScannerActive = true
    @State private var isCustomColorVisible = false
    @State private var scannerController: ScannerViewController?
    
    @State private var isScanned = false
    @State private var scannedTime: String?
    @State private var isLoading = false
    @AppStorage("isOfflineMode") private var isOffline: Bool = false
    @AppStorage("isMerchandise") private var isMerchandise: Bool?
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var toastMessage: String?
    @State private var showToast = false
    
    init(seat: Binding<SeatModel?>) {
        _linePosition = State(initialValue: 0)
        self._seat = seat
    }
    
    var body: some View {
        VStack {
            ZStack {
                CameraScannerView { scanned in
                    scannedCode = scanned
                    sendScanRequest(qr: scanned)
                    resetInactivityTimer()
                }
                .frame(height: scanViewHeight)
                
                if isCustomColorVisible {
                    Color.FDB_54_E
                        .opacity(1)
                        .frame(height: scanViewHeight)
                       // .padding(.top, 30)
                        .overlay(
                            Image("scan__cirle_icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .onTapGesture {
                                    resetScanner()
                                }
                        )
                }
                
                if !isCustomColorVisible {
                    Rectangle()
                        .frame(height: 1.5)
                        .foregroundColor(.red)
                        .shadow(color: .black, radius: 1.5)
                        .offset(y: linePosition - (scanViewHeight / 2))
                        .onAppear {
                            startLineAnimation()
                        }
                }
            }
            
            if showToast {
                Text(toastMessage ?? "")
                    .padding()
                    .foregroundColor(.white)
                    .padding()
                    .transition(.opacity)
                    .zIndex(1)
                    .padding(.top, 30)
            }
        }
        .onAppear {
            setupScanner()
            startInactivityTimer()
        }
        .onDisappear {
            stopLineAnimation()
            stopInactivityTimer()
        }
    }
    
    struct CameraScannerView: UIViewControllerRepresentable {
        var onScan: (String) -> Void
        
        func makeUIViewController(context: Context) -> ScannerViewController {
            let controller = ScannerViewController()
            controller.onScan = onScan
            return controller
        }
        
        func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
        
        static func dismantleUIViewController(_ uiViewController: ScannerViewController, coordinator: ()) {
            uiViewController.captureSession?.stopRunning()
        }
    }
    
    private func setupScanner() {
        flashLight = AVCaptureDevice.default(for: .video)
    }
    
    private func startLineAnimation() {
        withAnimation(Animation.linear(duration: Double(scanViewHeight / lineSpeed)).repeatForever(autoreverses: true)) {
            linePosition = scanViewHeight
        }
    }
    
    private func stopLineAnimation() {
        linePosition = 0
    }
    
    private func resetScanner() {
        isCustomColorVisible = false
        scannedCode = nil
        scanResult = nil
        isScanning = true
        isScannerActive = true
        linePosition = 0
        startLineAnimation()
        
        startInactivityTimer()
        
        if let scannerVC = scannerController {
            DispatchQueue.global(qos: .userInitiated).async {
                if scannerVC.captureSession?.isRunning == false {
                    scannerVC.captureSession?.startRunning()
                }
            }
        }
    }
    
    private func startInactivityTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
            self.activateColorOverlay()
            self.stopScanner()
        }
    }
    
    private func stopInactivityTimer() {
        timer?.invalidate()
    }
    
    private func resetInactivityTimer() {
        startInactivityTimer()
    }
    
    private func stopScanner() {
        isScannerActive = false
        scannerController?.captureSession?.stopRunning()
    }
    
    private func activateColorOverlay() {
        isCustomColorVisible = true
    }
    
    private func sendScanRequest(qr: String) {
        let cleanedQR = qr
            .replacingOccurrences(of: "{\"seat\":[", with: "")
            .replacingOccurrences(of: "{\"merch\":[", with: "")
            .replacingOccurrences(of: "]}", with: "")
            .replacingOccurrences(of: "\"", with: "")
        
        let qrCodes = cleanedQR.components(separatedBy: ",").filter { !$0.isEmpty }
        let isMerch = isMerchandise ?? false
        let scanType = isMerch ? "merch" : "seat"
        
        if isOffline {
            let separatedQRCodes = qrCodes.joined(separator: "-")
            
            if isMerch {
                let qrCodesArray = separatedQRCodes.components(separatedBy: "-")
                let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "qrCode IN %@", qrCodesArray)
                
                do {
                    let results = try viewContext.fetch(fetchRequest)
                    if let order = results.first {
                        if let scannedTime = order.date_scanned {
                            showToastMessage("This merchandise was already scanned at \(scannedTime).")
                        } else {
                            order.date_scanned = Date()
                            try viewContext.save()
                            showToastMessage("Merchandise scanned offline.")
                        }
                    } else {
                        showToastMessage("Error: Merchandise QR code not found.")
                    }
                } catch {
                    showToastMessage("Database error: \(error.localizedDescription)")
                }
            } else {
                let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "qrCode == %@", separatedQRCodes)
                
                do {
                    let results = try viewContext.fetch(fetchRequest)
                    if let seatEntity = results.first {
                        if let scannedTime = seatEntity.date_scanned {
                            showToastMessage("This ticket has been previously scanned at \(scannedTime).")
                        } else {
                            seatEntity.date_scanned = Date()
                            try viewContext.save()
                            showToastMessage("Ticket scanned offline.")
                        }
                    } else {
                        showToastMessage("Error: QR code not found in database.")
                    }
                } catch {
                    showToastMessage("Database error: \(error.localizedDescription)")
                }
            }
            
            if qr.allSatisfy({ $0.isNumber }) {
                let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "barcode == %@", qr)
                
                do {
                    let results = try viewContext.fetch(fetchRequest)
                    if let seatEntity = results.first {
                        if let scannedTime = seatEntity.date_scanned {
                            showToastMessage("This barcode has been previously scanned at \(scannedTime).")
                        } else {
                            seatEntity.date_scanned = Date()
                            try viewContext.save()
                            showToastMessage("Barcode scanned offline.")
                        }
                    } else {
                        showToastMessage("Barcode not found in the database.")
                    }
                } catch {
                    showToastMessage("Database error: \(error.localizedDescription)")
                }
            }
        } else {
            if qr.allSatisfy({ $0.isNumber }) {
                IQAPIClient.scanTicketBarcode(code: "36060-5E56", barcode: qr) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let responseData):
                            if let responseDict = responseData as? [String: Any], let message = responseDict["message"] as? String {
                                if message == "Previously Scanned" {
                                    if let scannedTime = responseDict["date_scanned"] as? String {
                                        showToastMessage("This ticket was previously scanned at \(scannedTime).")
                                    } else {
                                        showToastMessage("This ticket has been previously scanned.")
                                    }
                                } else {
                                    showToastMessage("Barcode scanned successfully.")
                                }
                            }
                        case .failure(let error):
                            showToastMessage("Error: \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                if isMerch {
                    IQAPIClient.scanProductQrCode(code: "36060-5E56", qr: qrCodes) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let responseData):
                                if let responseDict = responseData as? [String: Any], let message = responseDict["message"] as? String {
                                    if message == "Previously Scanned" {
                                        if let scannedTime = responseDict["date_scanned"] as? String {
                                            showToastMessage("This merchandise was previously scanned at \(scannedTime).")
                                        } else {
                                            showToastMessage("This merchandise has been previously scanned.")
                                        }
                                    } else {
                                        showToastMessage("Merchandise scanned successfully.")
                                    }
                                }
                            case .failure(let error):
                                showToastMessage("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    IQAPIClient.scanTicketQrCode(code: "36060-5E56", type: scanType, qr: qrCodes) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let responseData):
                                if let responseDict = responseData as? [String: Any] {
                                    do {
                                        let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                                        let decoder = JSONDecoder()
                                        guard let response = try? decoder.decode(ScanResponse.self, from: jsonData) else {
                                            showToastMessage("Ticket scanned successfully.")
                                            return
                                        }
                                        
                                        if response.valid == true {
                                            scanResult = "Ticket is valid. Seat: \(response.seat ?? 0), Section: \(response.section ?? "Unknown")"
                                            showToastMessage("Ticket scanned successfully.")
                                            seat?.scannedTime = Date()
                                            isScanning = false
                                        } else if response.message == "Previously Scanned" {
                                            showToastMessage("This ticket has been previously scanned.")
                                            isScanning = false
                                        } else {
                                            showToastMessage("Error: \(response.message ?? "Unknown error")")
                                            isScanning = false
                                        }
                                    } catch {
                                        showToastMessage("Failed to decode response: \(error.localizedDescription)")
                                        isScanning = false
                                    }
                                } else {
                                    showToastMessage("Error: Invalid response format.")
                                    isScanning = false
                                }
                            case .failure(let error):
                                showToastMessage("Error: \(error.localizedDescription)")
                                isScanning = false
                            }
                        }
                    }
                }
            }
        }
    }


    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
}

class ScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var onScan: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .hd1280x720
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            print("Error setting up camera input: \(error)")
            return
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInitiated))
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        
        captureSession = session
        captureSession?.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectBarcodesRequest { request, error in
            guard error == nil,
                  let results = request.results as? [VNBarcodeObservation],
                  let bestResult = results.first,
                  let payload = bestResult.payloadStringValue else { return }
            DispatchQueue.main.async {
                self.onScan?(payload)
                self.captureSession?.stopRunning()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.captureSession?.startRunning()
                }
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}
