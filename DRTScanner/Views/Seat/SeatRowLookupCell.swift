//
//  SeatRowLookupCell.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI

struct SeatRowLookupCell: View {
    var action: (() -> Void)?
    var selectedSeat: String
    var body: some View {
        HStack {
            Text(StringConstants.Common.row)
                .font(.verlagBookAdaptive(size: 27))
                .foregroundColor(Color.customGreen)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Text(selectedSeat.isEmpty ? "-" : selectedSeat)
                .font(.verlagBoldAdaptive(size: 40))
                .foregroundColor(Color.FFCE_62)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
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
        .onTapGesture {
            action?()
        }
    }
}
