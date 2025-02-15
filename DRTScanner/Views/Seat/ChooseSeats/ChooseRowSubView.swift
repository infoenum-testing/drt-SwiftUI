//
//  ChooseRowSubView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI

struct ChooseRowSubView: View {
    let seatLabels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"]
    @Binding var selectedSeat: String
    @Binding var isPresent: Bool
    
    var body: some View {
        VStack {
            List(seatLabels, id: \.self) { seat in
                ChooseRowCell(seatLabel: seat)
                    .frame(height: 80)
                    .onTapGesture {
                        selectedSeat = seat
                        isPresent = false
                    }
            }
            .listStyle(PlainListStyle())
            .background(Color.customWhite)
        }
        .background(Color.customWhite)
    }
}

struct ChooseRowCell: View {
    var seatLabel: String
    
    var body: some View {
        HStack {
            Text(seatLabel)
                .font(.custom("Verlag-Bold", size: 32))
                .foregroundColor(Color.showCodeButton)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.customWhite)
    }
}

struct ChooseRowCellView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseRowSubView(selectedSeat: .constant(""), isPresent: .constant(false))
    }
}
