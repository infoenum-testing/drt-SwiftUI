//
//  ShowOfflineAlertView.swift
//  DRTScanner
//
//  Created by IE15 on 01/08/25.
//
import SwiftUI

struct ShowOfflineAlertView:View {
    
    @ObservedObject var viewModel:LookupByOrderResultViewModel
    
    @Binding var showOfflineAlert:Bool
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Text(StringManager.shared.strings.errorMassage.error)
                    .padding(.leading, 20)
                    .font(.verlagBoldAdaptive(size: 30))
                    .foregroundColor(Color.primaryText)
                    .padding(.bottom, 10)
                    .padding(.top, 20)
                
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showOfflineAlert = false
                    }
                }) {
                    Image(StringConstants.DRTImages.crossImage)
                        .resizable()
                        .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                        .background(Color.clear)
                        .contentShape(Rectangle())
                }
            }
            
            VStack {
                Text(viewModel.errorMessage ?? "")
                    .font(.verlagBookAdaptive(size: 18))
                    .foregroundColor(Color.primaryText)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .padding([.horizontal,.bottom])
        .padding(.top,topSafeAreaPaddingHeader() - 10)
        .background(Color.secondaryBg)
    }
}
