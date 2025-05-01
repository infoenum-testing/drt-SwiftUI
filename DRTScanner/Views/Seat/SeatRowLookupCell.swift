//
//  SeatRowLookupCell.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI

struct SeatRowLookupCell: View {
    // Closure to be executed when the cell or button is tapped
    var action: (() -> Void)?
    // The currently selected seat to display
    var selectedSeat: String
    var body: some View {
        HStack {
            // Displays the label for the row (e.g., "Row")
            Text(StringConstants.Common.row)
                .font(.verlagBookAdaptive(size: 27))
                .foregroundColor(Color.customGreen)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Displays the selected Row or a dash if empty
            Text(selectedSeat.isEmpty ? "-" : selectedSeat)
                .font(.verlagBoldAdaptive(size: 40))
                .foregroundColor(Color.FFCE_62)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            // Button with an arrow image, triggers the action closure when tapped
            Button(action: {
                action?()
            }) {
                Image("right_side_arrow")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .background(Color.clear)
            .padding(.trailing, 25)
        }
        .padding([.top, .bottom], 10)
        .background(Color.white)
        .frame(height: 100)
        // Triggers the action closure when the entire cell is tapped
        .onTapGesture {
            action?()
        }
    }
}
