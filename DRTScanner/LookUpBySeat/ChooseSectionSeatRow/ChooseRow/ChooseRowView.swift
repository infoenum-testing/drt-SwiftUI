//
//  ChooseRowView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI

struct ChooseRowView: View {
    @State private var RowTitle: String = "ROW"
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
                
                    Text(stringManager.strings.seat.row)
                        .font(.verlagBlackAdaptive(size: 30))
                        .foregroundColor(Color.neutralText)
                        .padding(.trailing, 50)
                
                Spacer()
            }
            .padding(.horizontal,15.adaptiveForIpad)
            .frame(maxHeight: 90.adaptiveForIpad)
            .background(Color.neutralBg)
            
            ChooseRowSubView(selectedSeat: $selectedSeat, isPresent: $isPresented, selectedSection: $selectedSection, selectedRow: $selectedRow)
        }
        .background(Color.primaryText)
    }
}

struct ChooseRowView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseRowView(isPresented: .constant(true), selectedSeat: .constant(""), selectedSection: .constant(""), selectedRow: .constant(""))
    }
}
