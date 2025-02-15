//
//  TemplateView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 01/02/25.
//

import SwiftUI

struct TemplateView: View {
    @State var isshowSheet = false
        var body: some View {
            ZStack(alignment: .top){
                VStack{
                    Spacer()
                    Button(action: {
                        isshowSheet = true
                    }, label: {
                        Text("Button")
                    })
                    Spacer()
                }
                
                TopView(isShowSheet: $isshowSheet)
                
            }
        }
}

#Preview {
    TemplateView()
}

struct TopView: View {
    @Binding var isShowSheet: Bool
    @State private var viewHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            if isShowSheet {
                Button(action: {
                    isShowSheet.toggle()
                }, label: {
                    Text("Button")
                })
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: viewHeight)
        .background(Color.red)
        .onChange(of: isShowSheet) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 1.0)) {
                    viewHeight = UIScreen.main.bounds.height
                }
            } else {
                withAnimation(.easeInOut(duration: 1.0)) {
                    viewHeight = 0
                }
            }
        }
    }
}
