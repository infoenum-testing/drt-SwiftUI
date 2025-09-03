//
//  UIKitToggle.swift
//  DRTScanner
//
//  Created by DRT on 02/09/25.
//


import SwiftUI

struct UIKitToggle: UIViewRepresentable {
    @Binding var isOn: Bool
    var onColor: UIColor = .systemGreen
    var offColor: UIColor = .lightGray

    func makeUIView(context: Context) -> UISwitch {
        let uiSwitch = UISwitch()
        uiSwitch.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        return uiSwitch
    }
    
    func updateUIView(_ uiView: UISwitch, context: Context) {
        uiView.isOn = isOn
        uiView.onTintColor = onColor
        uiView.tintColor = offColor
        uiView.layer.cornerRadius = uiView.frame.height / 2.0
        uiView.backgroundColor = offColor
        uiView.clipsToBounds = true
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: UIKitToggle
        
        init(_ parent: UIKitToggle) {
            self.parent = parent
        }
        
        @objc func valueChanged(_ sender: UISwitch) {
            parent.isOn = sender.isOn
        }
    }
}
