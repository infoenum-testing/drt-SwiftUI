//
//  DRTScanQrCodeView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//


import SwiftUI
import AVFoundation

struct DRTScanQrCodeView: View {
    @StateObject private var scannerViewModel = QRScannerViewModel()
    
    var body: some View {
        ZStack {
            QRScannerView(session: scannerViewModel.session)
                .edgesIgnoringSafeArea(.all)
            
            if let scannedCode = scannerViewModel.scannedCode {
                VStack {
                    Text("Scanned QR Code:")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                    Text(scannedCode)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }
            }
        }
        .onAppear {
            scannerViewModel.startScanning()
        }
    }
}

struct DRTScanQrCodeView_Previews: PreviewProvider {
    static var previews: some View {
        DRTScanQrCodeView()
    }
}

class QRScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var scannedCode: String?
    let session = AVCaptureSession()
    
    private let metadataOutput = AVCaptureMetadataOutput()

    override init() {
        super.init()
        setupScanner()
    }

    func setupScanner() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }

        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }
    }

    func startScanning() {
        if !session.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let stringValue = metadataObject.stringValue {
            DispatchQueue.main.async {
                self.scannedCode = stringValue
                self.session.stopRunning()
            }
        }
    }
}


struct QRScannerView: UIViewControllerRepresentable {
    let session: AVCaptureSession
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        controller.view.layer.addSublayer(previewLayer)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
