//
//  ChooseSeatCell.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/04/25.
//

import SwiftUI

struct ChooseSeatCell: View {
    var seatLabel: String
    
    var body: some View {
        HStack {
            Text(seatLabel)
                .font(.verlagBoldAdaptive(size: 32))
                .foregroundColor(Color.secondaryBg)
                .frame(maxWidth: .infinity, alignment: .center)
            
        }.listRowSeparator(.hidden)
        .padding()
        .background(Color.primaryText)
    }
}

struct ChooseSeatCellView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSeatSubView(selectedSeat: .constant(""), isPresent: .constant(false), selectedSection: .constant(""), selectedRow: .constant(""))
    }
}
