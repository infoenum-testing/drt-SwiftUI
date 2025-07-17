//
//  ChooseRowView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI

struct ChooseRowView: View {
    @State private var isLoading = false
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
                    isPresented = false
                }) {
                    Image(StringConstants.DRTImages.leftSideArrow)
                        .foregroundStyle(Color.neutralText)
                }.padding()
                    .padding(.leading, 20)
                    .frame(height: 85.adaptiveForIpad, alignment: .center)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.primaryText))
                        .frame(width: 20, height: 20)
                } else {
                    Text(stringManager.strings?.seat.row ?? RowTitle)
                        .font(.verlagBlackAdaptive(size: 30))
                        .foregroundColor(Color.neutralText)
                        .padding(.trailing, 50)
                }
                
                Spacer()
            }
            .background(Color.neutralBg)
            HStack {
                ChooseRowSubView(selectedSeat: $selectedSeat, isPresent: $isPresented, selectedSection: $selectedSection, selectedRow: $selectedRow)
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

struct ChooseRowView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseRowView(isPresented: .constant(true), selectedSeat: .constant(""), selectedSection: .constant(""), selectedRow: .constant(""))
    }
}
