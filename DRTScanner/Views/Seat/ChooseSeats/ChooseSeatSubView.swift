//
//  ChooseSeatSubView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI

struct ChooseSeatSubView: View {
    let seatLabels = ["201", "202", "203", "204", "205", "206", "207", "208", "209", "210", "211"]
    @Binding var selectedSeat: String
    @Binding var isPresent: Bool
    
    var body: some View {
        VStack {
            List(seatLabels, id: \.self) { seat in
                ChooseSeatCell(seatLabel: seat)
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

struct ChooseSeatCell: View {
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

struct ChooseSeatCellView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSeatSubView(selectedSeat: .constant(""), isPresent: .constant(false))
    }
}
