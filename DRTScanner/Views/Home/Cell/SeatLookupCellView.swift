//
//  SeatLookupCellView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 10/02/25.
//


import SwiftUI

struct SeatLookupCellView: View {
    let seatName: String
    let seatType: String
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(seatName)
                    .foregroundColor(isEnabled ? Color("color_2_bg") : .gray)
                    .font(.headline)
                
                Text(seatType)
                    .foregroundColor(isEnabled ? Color("color_1_bg") : .gray)
                    .font(.subheadline)
            }
            Spacer()
            
            Button(action: {
                print("\(seatName) tapped")
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(isEnabled ? .blue : .gray)
            }
            .disabled(!isEnabled)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    SeatLookupCellView(seatName: "", seatType: "", isEnabled: true)
}
