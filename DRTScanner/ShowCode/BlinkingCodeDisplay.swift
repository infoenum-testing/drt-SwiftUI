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
                ZStack {
                    Text(placeholder)
                        .font(.verlagBoldAdaptive(size: 35))
                        .foregroundColor(Color.primaryText.opacity(0.5))
                        .id("placeholder")
                    Rectangle()
                        .fill(showCursor ? Color.primaryText : Color.clear)
                        .frame(width: 2, height: 35.adaptiveForIpad)
                        .padding(.leading, 2)
                        .id("cursor")
                }
                .frame(height: 40.adaptiveForIpad)
            } else {
                GeometryReader { geo in
                    let needsScroll = textWidth > geo.size.width
                    ScrollView(.horizontal, showsIndicators: false) {
                        ScrollViewReader { proxy in
                            ZStack {
                                HStack(spacing: 0) {
                                    Text(code)
                                        .font(.verlagBoldAdaptive(size: 35))
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
                                        .offset(x: centerOffset(for: geo.size.width))
                                    Rectangle()
                                        .fill(showCursor ? Color.primaryText : Color.clear)
                                        .frame(width: 2, height: 35.adaptiveForIpad)
                                        .padding(.leading, 2)
                                        .offset(x: centerOffset(for: geo.size.width + 2))
                                        .id("cursor")
                                }
                            }
                            .onAppear {
                                availableWidth = geo.size.width
                                scrollProxy = proxy
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
                .frame(height: 40.adaptiveForIpad) // match TextField height
            }
        }
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
    private func centerOffset(for availableWidth: CGFloat) -> CGFloat {
        if textWidth == 0 { return 0 }
        
        let centeredOffset = (availableWidth - textWidth) / 2
        return max(0, centeredOffset) // if text wider, stick to leading
    }
}
