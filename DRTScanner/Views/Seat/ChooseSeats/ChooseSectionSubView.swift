//
//  ChooseSectionSubView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//


import SwiftUI

struct ChooseSectionSubView: View {
    let seatLabels = ["B", "O", "OL", "OR", "VIP1", "VIP2"]
    @Binding var selectedSeat: String
    @Binding var isPresent: Bool
    
    var body: some View {
        VStack {
            List(seatLabels, id: \.self) { seat in
                ChooseSectionCell(seatLabel: seat)
                    .frame(height: 80)
                
                    .onTapGesture {
                        selectedSeat = seat
                        isPresent = false
                    }
                Divider()
            }
            .listStyle(.plain)
            .background(Color.customWhite)
        }
        .background(Color.customWhite)
    }
}

struct ChooseSectionCell: View {
    var seatLabel: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(seatLabel)
                .font(.custom("Verlag-Bold", size: 32))
                .foregroundColor(Color.showCodeButton)
            Spacer()
        }.listRowSeparator(.hidden)
        .background(Color.customWhite)
    }
}

struct ChooseSectionCellView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSectionSubView(selectedSeat: .constant(""), isPresent: .constant(false))
    }
}
