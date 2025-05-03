//
//  ExternalBarcodeInputField.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/04/25.
//

import SwiftUI
import UIKit

// A SwiftUI wrapper for a custom UITextField that handles external barcode input
struct ExternalBarcodeInputField: UIViewRepresentable {
    // The scanned barcode value, bound to parent view
    @Binding var scannedCode: String
    // Controls whether the text field is active (focused)
    @Binding var isActive: Bool
    
    // Coordinator acts as the delegate for UITextField and manages barcode input logic
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: ExternalBarcodeInputField
        var lastInputDate: Date?
        
        init(parent: ExternalBarcodeInputField) {
            self.parent = parent
        }
        
        // Called whenever the text in the UITextField changes
        @objc func textChanged(_ textField: UITextField) {
            guard parent.isActive else {
                textField.text = ""
                return
            }
            
            let currentText = textField.text ?? ""
            let now = Date()
            
            // Set delay based on environment (simulator or device)
            let delay: TimeInterval = {
#if targetEnvironment(simulator)
                return 2.0
#else
                return 0.5
#endif
            }()
            
            // If input is too fast, delay handling the scanned code
            if let lastDate = lastInputDate, now.timeIntervalSince(lastDate) < delay {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(handleScannedCode(_:)), object: textField)
                perform(#selector(handleScannedCode(_:)), with: textField, afterDelay: delay)
            } else if currentText.count > 0 {
                // If only one character, keep the last character
                textField.text = String(currentText.suffix(1))
            }
            
            lastInputDate = now
        }
        
        // Handles the scanned code after the delay
        @objc func handleScannedCode(_ textField: UITextField) {
            guard let code = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !code.isEmpty else { return }
            
            parent.scannedCode = code
            textField.text = ""
        }
    }
    
    // Creates the coordinator instance
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // Creates the UITextField and configures its properties
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = .asciiCapable
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.inputView = UIView()
        textField.inputAccessoryView = UIView()
        textField.delegate = context.coordinator
        
        if #available(iOS 13.0, *) {
            textField.inputAssistantItem.leadingBarButtonGroups = []
            textField.inputAssistantItem.trailingBarButtonGroups = []
        }
        
        // Listen for text changes
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        
        return textField
    }
    
    // Updates the UITextField's responder status based on isActive
    func updateUIView(_ uiView: UITextField, context: Context) {
        if isActive {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        } else {
            DispatchQueue.main.async {
                uiView.resignFirstResponder()
            }
        }
    }
}
