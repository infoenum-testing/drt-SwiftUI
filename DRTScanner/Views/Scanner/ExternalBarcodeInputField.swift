//
//  ExternalBarcodeInputField.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/04/25.
//


import SwiftUI
import UIKit

struct ExternalBarcodeInputField: UIViewRepresentable {
    @Binding var scannedCode: String
    @Binding var isActive: Bool
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: ExternalBarcodeInputField
        var lastInputDate: Date?
        
        init(parent: ExternalBarcodeInputField) {
            self.parent = parent
        }
        
        @objc func textChanged(_ textField: UITextField) {
            guard parent.isActive else {
                textField.text = ""
                return
            }
            
            let currentText = textField.text ?? ""
            let now = Date()
            
            let delay: TimeInterval = {
#if targetEnvironment(simulator)
                return 2.0
#else
                return 0.5
#endif
            }()
            
            if let lastDate = lastInputDate, now.timeIntervalSince(lastDate) < delay {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(handleScannedCode(_:)), object: textField)
                perform(#selector(handleScannedCode(_:)), with: textField, afterDelay: delay)
            } else if currentText.count > 0 {
                textField.text = String(currentText.suffix(1))
            }
            
            lastInputDate = now
        }
        
        @objc func handleScannedCode(_ textField: UITextField) {
            guard let code = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !code.isEmpty else { return }
            
            parent.scannedCode = code
            textField.text = ""
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
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
        
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        
        return textField
    }
    
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
