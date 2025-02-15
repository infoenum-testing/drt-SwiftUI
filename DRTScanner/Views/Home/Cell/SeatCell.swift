//
//  SeatCell.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.
//
import SwiftUI

struct SeatCell: View {
    let seat: SeatModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text("NOT YET SCANNED")
                    .font(Font.custom("Verlag-Bold", size: 20))
                    .foregroundColor(.showCodeText)
            }
            HStack(alignment: .center) {
                HStack(alignment: .bottom, spacing: 0) {
                    Text("SECT:")
                        .font(Font.custom("Verlag-Bold", size: 10))
                        .foregroundColor(.showCodeText)
                    Text("\(seat.section)")
                        .font(Font.custom("Verlag-Bold", size: 15))
                        .foregroundColor(.showCodeText)
                }
                Spacer()
                HStack(alignment: .bottom, spacing: 0) {
                    Text("ROW:")
                        .font(Font.custom("Verlag-Bold", size: 10))
                        .foregroundColor(.showCodeText)
                    Text("\(seat.row)")
                        .font(Font.custom("Verlag-Bold", size: 15))
                        .foregroundColor(.showCodeText)
                }
                Spacer()
                HStack(alignment: .bottom, spacing: 0) {
                    Text("SEAT:")
                        .font(Font.custom("Verlag-Bold", size: 10))
                        .foregroundColor(.showCodeText)
                    
                    Text("\(seat.seat)")
                        .font(Font.custom("Verlag-Bold", size: 15))
                        .foregroundColor(.showCodeText)
                }

                Spacer()
                Image("scan_now")
            }
           // .padding([.top, .bottom])
        }
        .background(Color.customWhite)
        .padding(0)
    }
}
