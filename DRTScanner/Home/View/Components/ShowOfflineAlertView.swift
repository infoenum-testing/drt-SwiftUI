//
//  ShowOfflineAlertView.swift
//  DRTScanner
//
//  Created by IE15 on 01/08/25.
//
import SwiftUI

struct ShowOfflineAlertView:View {
    
    @ObservedObject var viewModel: LookupByOrderResultViewModel
    
    @Binding var showOfflineAlert:Bool
    @Binding var showAlertText: Bool
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                CustomsText(title: showAlertText ? StringManager.shared.strings.dialogLogout.whenOfflineTitle : StringManager.shared.strings.errorMassage.error, textFont: .verlagBoldAdaptive(size: 30), foregroundColour: .primaryText)
                    .padding([.top,.leading], 20)
                    .padding(.bottom, 10)
                
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
                CustomsText(title: viewModel.errorMessage ?? "", textFont: .verlagBookAdaptive(size: 18), foregroundColour: .primaryText, alignment: .center)
                    .padding()
            }
        }
        .padding([.horizontal,.bottom])
        .padding(.top,topSafeAreaPaddingHeader() - 10)
        .background(Color.secondaryBg)
    }
}
