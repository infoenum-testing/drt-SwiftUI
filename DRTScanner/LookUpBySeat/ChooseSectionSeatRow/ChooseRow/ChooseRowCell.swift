//
//  ChooseRowCell.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/04/25.
//

import SwiftUI

struct ChooseRowCell: View {
    var row: String
    
    var body: some View {
        HStack {
            Text(row)
                .font(.verlagBoldAdaptive(size: 32))
                .foregroundColor(Color.secondaryBg)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .listRowSeparator(.hidden)
        .background(Color.primaryText)
    }
}

struct ChooseRowCellView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseRowSubView(selectedSeat: .constant(""), isPresent: .constant(false), selectedSection: .constant(""), selectedRow: .constant(""))
    }
}
