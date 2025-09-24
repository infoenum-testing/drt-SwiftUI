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
                
                    Text(stringManager.strings.seat.seat)
                        .font(.verlagBlackAdaptive(size: 30))
                        .foregroundColor(.neutralText)
                        .padding(.trailing, 50)
                Spacer()
            }
            .padding(.horizontal,15.adaptiveForIpad)
            .frame(maxHeight: 90.adaptiveForIpad)
            .background(Color.neutralBg)
            
            ChooseSeatSubView(selectedSeat: $selectedSeat, isPresent: $isPresented, selectedSection: $selectedSection, selectedRow: $selectedRow)
        }
        .frame(maxHeight: .infinity)
        .background(Color.primaryText)
        
    }
}

struct ChooseSeatView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSeatView(isPresented: .constant(true), selectedSeat: .constant(""), selectedSection: .constant(""), selectedRow: .constant(""))
    }
}
