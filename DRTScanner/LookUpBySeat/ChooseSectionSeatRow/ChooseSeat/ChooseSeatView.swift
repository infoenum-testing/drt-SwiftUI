//
//  ChooseSeatView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI

struct ChooseSeatView: View {
    @State private var isLoading = false
    @State private var sectionsTitle: String = "SEAT"
    @Binding var isPresented: Bool
    @Binding var selectedSeat: String
    @Binding var selectedSection: String
    @Binding var selectedRow: String
    @EnvironmentObject var stringManager: StringManager
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(StringConstants.DRTImages.leftSideArrow)
                        .foregroundStyle(Color.neutralText)
                        .padding(10.adaptiveForIpad)
                }
                    .padding(.leading, 10.adaptiveForIpad)
                .frame(height: 85, alignment: .center)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                        .frame(width: 20, height: 20)
                } else {
                    Text(stringManager.strings?.seat.seat ?? sectionsTitle)
                        .font(.verlagBlackAdaptive(size: 30))
                        .foregroundColor(.neutralText)
                        .padding(.trailing, 50)
                }
                
                Spacer()
            }
            .background(Color.neutralBg)
            HStack {
                ChooseSeatSubView(selectedSeat: $selectedSeat, isPresent: $isPresented, selectedSection: $selectedSection, selectedRow: $selectedRow)
            }
        }.frame(maxHeight: .infinity)
        .background(Color.primaryText)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }
}

struct ChooseSeatView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSeatView(isPresented: .constant(true), selectedSeat: .constant(""), selectedSection: .constant(""), selectedRow: .constant(""))
    }
}
