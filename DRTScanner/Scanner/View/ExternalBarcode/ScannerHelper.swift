//
//  ScannerHelper.swift
//  DRTScanner
//
//  Created by IE15 on 29/07/25.
//

import Foundation
import SwiftUI
import SwiftUICore

@ViewBuilder
func statsRow(title: String, value: Int) -> some View {
    HStack {
        Text(title)
            .font(.headline)
        Spacer()
        Text("\(value)")
            .font(.title3)
            .bold()
    }
    .padding()
}

extension UIApplication {
    var topSafeAreaHeight: CGFloat {
        let scene = connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets.top ?? 0
    }
}

enum ScannerResult {
    case invalid
    case valid
    case previouslyScanned
}
