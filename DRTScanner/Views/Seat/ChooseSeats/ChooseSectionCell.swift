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
                .font(.custom(StringConstants.DRTFont.verlagBold, size: 32))
                .foregroundColor(Color.FFCE_62)
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
