//
//  ChooseSectionCell.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/04/25.
//

import SwiftUI

struct ChooseSectionCell: View {
    var seatLabel: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(seatLabel)
                .font(.verlagBoldAdaptive(size: 32))
                .foregroundColor(Color.secondaryBg)
            Spacer()
        }.listRowSeparator(.hidden)
            .background(Color.primaryText)
    }
}

struct ChooseSectionCellView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSectionSubView(selectedSeat: .constant(""), isPresent: .constant(false))
    }
}
