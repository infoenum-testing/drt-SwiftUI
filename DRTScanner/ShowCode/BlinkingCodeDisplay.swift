//
//  BlinkingCodeDisplay.swift
//  DRTScanner
//
//  Created by IE15 on 11/08/25.
//

import SwiftUI
import SwiftUI

import SwiftUI

struct BlinkingCodeDisplay: View {
    var placeholder: String
    @Binding var code: String
    @State private var showCursor = true
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var textWidth: CGFloat = 0
    @State private var availableWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            let needsScroll = textWidth > geo.size.width
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { proxy in
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
                                .background(
                                    GeometryReader { textGeo in
                                        Color.clear
                                            .onAppear {
                                                textWidth = textGeo.size.width
                                            }
                                            .onChange(of: code) { _ in
                                                textWidth = textGeo.size.width
                                            }
                                    }
                                )
                                .id("text")
                            
                            Rectangle()
                                .fill(showCursor ? Color.primaryText : Color.clear)
                                .frame(width: 2, height: 40)
                                .padding(.leading, 2)
                                .id("cursor")
                        }
                    }
                    .onAppear {
                        availableWidth = geo.size.width
                        scrollProxy = proxy
                        startBlinking()
                    }
                    .onChange(of: code) { _ in
                        if needsScroll {
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo("cursor", anchor: .trailing)
                            }
                        }
                    }
                }
            }
            .scrollDisabled(!needsScroll)
        }
        .frame(height: 50) // match TextField height
    }
    
    private func startBlinking() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                showCursor.toggle()
            }
        }
    }
}
