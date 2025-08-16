//
//  BlinkingCodeDisplay.swift
//  DRTScanner
//
//  Created by IE15 on 11/08/25.
//

import SwiftUI

struct BlinkingCodeDisplay: View {
    var placeholder: String
    @Binding var code: String
    @State private var showCursor = false
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var textWidth: CGFloat = 0
    @State private var availableWidth: CGFloat = 0
    @State private var isCurcerShowing: Bool = false
    var body: some View {
                    ZStack {
                        if code.isEmpty {
                            Text(placeholder)
                                .font(.verlagBoldAdaptive(size: 40))
                                .foregroundColor(Color.primaryText.opacity(0.5))
                                .id("placeholder")
                        }
                        HStack(spacing: 0) {
                            Text(code)
                                .font(.verlagBoldAdaptive(size: 40))
                                .foregroundColor(Color.primaryText)
                                .id("text")
                            
                            Rectangle()
                                .fill(showCursor ? Color.primaryText : Color.clear)
                                .frame(width: 2, height: 40)
                                .padding(.leading, 2)
                                .id("cursor")
                        }
                    }

        .frame(height: 50) // match TextField height
        .onTapGesture {
            if !isCurcerShowing {
                isCurcerShowing = true
                startBlinking()
            }
        }
        .onChange(of: code) {newValue in
            if !isCurcerShowing {
                isCurcerShowing = true
                startBlinking()
            }
        }
    }
    
    private func startBlinking() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                showCursor.toggle()
            }
        }
    }
}
