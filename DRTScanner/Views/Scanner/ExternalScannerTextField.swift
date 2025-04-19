//
//  ExternalScannerTextField.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 18/04/25.
//


import SwiftUI

struct ExternalScannerTextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: ExternalScannerTextField
        var buffer = ""

        init(_ parent: ExternalScannerTextField) {
            self.parent = parent
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            buffer += string

            // Optional: You can add a filter to allow only alphanumeric/QR characters here

            NSObject.cancelPreviousPerformRequests(withTarget: self)
            perform(#selector(triggerScan), with: nil, afterDelay: 0.15) // Allow time for full scan
            return false
        }

        @objc private func triggerScan() {
            if !buffer.isEmpty {
                parent.onScan(buffer.trimmingCharacters(in: .whitespacesAndNewlines))
                buffer = ""
            }
        }
    }

    var onScan: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.keyboardType = .asciiCapable
        textField.isHidden = true // Keeps it hidden but functional
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if !uiView.isFirstResponder {
            uiView.becomeFirstResponder() // Keep keyboard focus to accept input from scanner
        }
    }
}
