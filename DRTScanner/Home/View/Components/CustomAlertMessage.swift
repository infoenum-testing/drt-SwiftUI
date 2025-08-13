//
//  CustomAlertMessage.swift
//  DRTScanner
//
//  Created by IE15 on 01/08/25.
//
import SwiftUI

// Custom alert for error messages
struct CustomAlertMessage:View {
    
    @EnvironmentObject var stringManager: StringManager
    
    var body: some View {
        
        VStack(alignment: .center) {
            HStack {
                Text("")
                    .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                Spacer()
                
                Text(StringManager.shared.strings.errorMassage.error)
                    .font(.verlagBoldAdaptive(size: 30))
                    .foregroundColor(Color.primaryText)
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        stringManager.isShowAlert = false
                    }
                }) {
                    Image(StringConstants.DRTImages.crossImage)
                        .resizable()
                        .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                        .background(Color.clear)
                        .contentShape(Rectangle())
                }
            }
            
            Text(stringManager.message)
                .font(.verlagBookAdaptive(size: 18))
                .foregroundColor(Color.primaryText)
                .multilineTextAlignment(.center)
                .padding(.top,5)
            
        }
        .padding([.horizontal,.bottom])
        .padding(.top,topSafeAreaPaddingHeader())
        .background(Color.secondaryBg)
    }
}
