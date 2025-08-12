//
//  ChooseSectionView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//


import SwiftUI

struct ChooseSectionView: View {
    @State private var isLoading = false
    @State private var sectionsTitle: String = "SECTION"
    @Binding var isPresented: Bool
    @Binding var selectedSeat: String
    @EnvironmentObject var stringManager: StringManager
    
    var body: some View {
        VStack(spacing:0) {
            HStack {
                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Image(StringConstants.DRTImages.leftSideArrow)
                        .resizable()
                        .frame(width: 20.adaptiveForIpad, height: 30.adaptiveForIpad, alignment: .center)
                        .foregroundStyle(Color.neutralText)
                        .padding(10.adaptiveForIpad)
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                        .frame(width: 20, height: 20)
                } else {
                    Text(stringManager.strings?.seat.section ?? sectionsTitle)
                        .font(.verlagBlackAdaptive(size: 30))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.neutralText)
                        .padding(.trailing, 50)
                }
                
                Spacer()
            }
            .padding(.horizontal,15.adaptiveForIpad)
            .frame(maxHeight: 90.adaptiveForIpad)
            .background(Color.neutralBg)
            VStack {
                ChooseSectionSubView(selectedSeat: $selectedSeat, isPresent: $isPresented)
            }
        }
        .background(Color.primaryText)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }
}

struct ChooseSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSectionView(isPresented: .constant(true), selectedSeat: .constant(""))
    }
}
