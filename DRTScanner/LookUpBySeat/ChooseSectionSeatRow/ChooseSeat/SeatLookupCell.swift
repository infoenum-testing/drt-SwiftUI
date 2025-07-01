//
//  SeatLookupCell.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI

struct SeatLookupCell: View {
    // Closure to be executed when the cell or button is tapped
    var action: (() -> Void)?
    // The currently selected seat to display
    var selectedSeat: String
    @EnvironmentObject var stringManager: StringManager
    var body: some View {
        HStack {
            // Displays the seat label
            Text(stringManager.strings?.seat.seat ?? StringConstants.LandingView.seatSection)
                .font(.verlagBookAdaptive(size: 27))
                .foregroundColor(Color.customGreen)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Displays the selected seat or '-' if empty
            Text(selectedSeat.isEmpty ? "-" : selectedSeat)
                .font(.verlagBoldAdaptive(size: 40))
                .foregroundColor(Color.FFCE_62)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
            
            // Button with right arrow image, triggers the action closure
            Button(action: {
                action?()
            }) {
                Image(StringConstants.SeatHomeView.rightSideArrow)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .background(Color.clear)
            .padding(.trailing, 25)
        }
        .padding([.top, .bottom], 10)
        .background(Color.white)
        .frame(height: 100)
        // Triggers the action closure when the cell is tapped
        .onTapGesture {
            action?()
        }
    }
}
