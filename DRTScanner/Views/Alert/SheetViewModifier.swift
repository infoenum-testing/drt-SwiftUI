//
//  SheetViewModifier.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 07/02/25.
//

import SwiftUICore

struct SheetViewModifier<AlertContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @State private var viewHeight: CGFloat = 0
    let content: () -> AlertContent
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: isPresented ? 0 : 0)
                .animation(.easeInOut(duration: 0.3), value: isPresented)
            
            
            if isPresented {
                Color.black.opacity(0.0)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }
                
                self.content()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
                    .offset(y: 0)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}

extension View {
    func customSheetView<AlertContent: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> AlertContent) -> some View {
        self.modifier(SheetViewModifier(isPresented: isPresented, content: content))
    }
}
