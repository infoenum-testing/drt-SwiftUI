//
//  AlertViewModifier.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 31/01/25.
//


import SwiftUI

struct AlertViewModifier<AlertContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @State private var viewHeight: CGFloat = 0
    let content: () -> AlertContent
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .blur(radius: isPresented ? 0 : 0)
                .animation(.easeInOut(duration: 0.3), value: isPresented)
            
            if isPresented {
                Color.black.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .allowsHitTesting(true)
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }
                
                self.content()
                    .frame(maxWidth: .infinity)
                    .offset(y: 0)
                    .transition(.move(edge: .top))
                    .ignoresSafeArea(.container, edges: .top)
            }
        }
    }
}

extension View {
    func customAlert<AlertContent: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> AlertContent) -> some View {
        self.modifier(AlertViewModifier(isPresented: isPresented, content: content))
    }
}
