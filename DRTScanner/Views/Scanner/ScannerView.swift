//
//  ScannerView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/02/25.
//


import AVKit
import SwiftUI

struct ScannerView: View {
    @State private var flashLight: AVCaptureDevice?
    @State private var scanViewHeight: CGFloat = UIScreen.main.bounds.height * 3 / 8.5
    @State private var linePosition: CGFloat
    private let lineSpeed: CGFloat = 70.0
    
    init() {
        _linePosition = State(initialValue: (UIScreen.main.bounds.height * 3 / 7) / 70)
    }
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .frame(height: scanViewHeight)
                    .foregroundColor(.showCodeButton)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.red)
                    .shadow(color: .black, radius: 1.5, x: 0.5, y: 0.5)
                    .offset(y: linePosition - (scanViewHeight / 2))
                    .onAppear {
                        startLineAnimation()
                    }
            }
        }
        .onAppear {
            setupScanner()
        }
        .onDisappear {
        }.padding(.bottom, -10)
    }
    
     private func setupScanner() {
        flashLight = AVCaptureDevice.default(for: .video)
    }
    
    private func startLineAnimation() {
        withAnimation(Animation.linear(duration: Double(scanViewHeight / lineSpeed)).repeatForever(autoreverses: true)) {
            linePosition = scanViewHeight
        }
    }
    
    private func flashButtonAction() {
        toggleFlashlight()
    }
    
    private func toggleFlashlight() {
        guard let device = flashLight, device.isTorchAvailable else { return }
        
        do {
            try device.lockForConfiguration()
            if device.torchMode == .on {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: 1.0)
            }
            device.unlockForConfiguration()
        } catch {
            print("Error toggling flashlight")
        }
    }
    
    private func checkForFlashlight() {
        if let device = flashLight, device.isTorchAvailable {
        } else {
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView()
    }
}
