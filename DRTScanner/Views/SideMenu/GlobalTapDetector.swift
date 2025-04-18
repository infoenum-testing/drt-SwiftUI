//
//  GlobalTapDetector.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 09/04/25.
//

import SwiftUI

struct GlobalTapGestureModifier: ViewModifier {
    var disabled: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(GlobalTapCatcher(disabled: disabled))
    }
    
    struct GlobalTapCatcher: UIViewControllerRepresentable {
        var disabled: Bool
        
        func makeUIViewController(context: Context) -> UIViewController {
            let controller = UIViewController()
            DispatchQueue.main.async {
                if let window = controller.view.window {
                    let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
                    tapRecognizer.cancelsTouchesInView = false
                    tapRecognizer.delegate = context.coordinator
                    window.addGestureRecognizer(tapRecognizer)
                }
            }
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            context.coordinator.disabled = disabled
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(disabled: disabled)
        }
        
        class Coordinator: NSObject, UIGestureRecognizerDelegate {
            var disabled: Bool
            
            init(disabled: Bool) {
                self.disabled = disabled
            }
            
            @objc func handleTap() {
                if !disabled {
                    print("✅ Global tap detected via UIWindow (handleTap)")
                    InactivityManager.shared.resetTimer()
                } else {
                    print("⚠️ Tap ignored because detection is disabled")
                }
            }
            
            func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
                let touchedView = touch.view
                print("👆 Touch received on: \(String(describing: touchedView))")
                
                return true
            }
            
            func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
                print("🤝 Allowing simultaneous gesture recognition")
                return true
            }
        }
    }
}

extension View {
    func detectGlobalTaps(disabled: Bool = false) -> some View {
        self.modifier(GlobalTapGestureModifier(disabled: disabled))
    }
}
