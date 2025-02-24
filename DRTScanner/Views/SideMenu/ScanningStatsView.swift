//
//  ScanningStatsView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//


import SwiftUI

struct ScanningStatsView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Spacer()
                Text("Scanning Stats")
                    .font(Font.custom("Verlag-Bold", size: 30))
                    .foregroundColor(.customWhite)
                    .frame(alignment: .center)
                    .padding(.leading, 10)
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isPresented = false
                    }
                }) {
                    Image("Popup_cross_btn")
                        .padding([.bottom, .top])
                }
            }
            HStack {
                Text("Total Seats:")
                    .font(Font.custom("Avenir-Light", size: 20))
                    .foregroundColor(.customWhite)
                Spacer()
                Text("672")
                    .font(Font.custom("Avenir-Light", size: 20))
                    .foregroundColor(.customWhite)
            }
            HStack {
                Text("Total Scannable Seats: ")
                    .font(Font.custom("Avenir-Light", size: 20))
                    .foregroundColor(.customWhite)
                Spacer()
                Text("576")
                    .font(Font.custom("Avenir-Light", size: 20))
                    .foregroundColor(.customWhite)
            }
            HStack {
                Text("Total Scanned Seats: ")
                    .font(Font.custom("Avenir-Light", size: 20))
                    .foregroundColor(.customWhite)
                Spacer()
                Text("0")
                    .font(Font.custom("Avenir-Light", size: 20))
                    .foregroundColor(.customWhite)
            }
            HStack {
                Text("Tickets Scanned by Device:")
                    .font(Font.custom("Avenir-Light", size: 20))
                    .foregroundColor(.customWhite)
                Spacer()
                Text("0")
                    .font(Font.custom("Avenir-Light", size: 20))
                    .foregroundColor(.customWhite)
            }
        }
        .padding(20)
        .background(.showCodeButton)
    }
}
