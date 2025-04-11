//
//  GlobalTapDetector.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 09/04/25.
//

import SwiftUI

struct GlobalTapDetector: ViewModifier {
    var disabled: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(
                TapForwarder(disabled: disabled)
            )
    }
    
    struct TapForwarder: UIViewRepresentable {
        var disabled: Bool
        
        func makeUIView(context: Context) -> TapDetectingView {
            let view = TapDetectingView()
            view.disabled = disabled
            view.onTap = {
                if !disabled {
                    print("✅ Global tap detected")
                    InactivityManager.shared.resetTimer()
                }
            }
            return view
        }
        
        func updateUIView(_ uiView: TapDetectingView, context: Context) {
            uiView.disabled = disabled
        }
    }
    
    class TapDetectingView: UIView {
        var onTap: (() -> Void)?
        var disabled: Bool = false
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            _ = super.hitTest(point, with: event)
            if !disabled {
                onTap?()
            }
            return nil
        }
    }
}

extension View {
    func detectGlobalTaps(disabled: Bool = false) -> some View {
        self.modifier(GlobalTapDetector(disabled: disabled))
    }
}
