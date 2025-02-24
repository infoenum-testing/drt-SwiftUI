//
//  LookupCellView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 18/02/25.
//

import SwiftUI

struct LookupCellView: View {
    var result: Orders
    var onCellTapped: (Int) -> Void
    @State private var isTapped = false
    
    var body: some View {
        VStack(alignment: .center) {
            Text(result.buyerName ?? "")
                .font(.custom("Verlag-Black", size: 24))
                .foregroundColor(Color.showCodeText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 0)
            
            HStack {
                
                Text("ORDER: \(result.orderId ?? 0)")
                    .font(.custom("Verlag-Bold", size: 15))
                    .foregroundColor(Color.showCodeText)
                
                Text("CC: \(result.cc ?? "")")
                    .font(.custom("Verlag-Bold", size: 15))
                    .foregroundColor(Color.showCodeText)
            }
            .padding(.top, 0)
            
            Text("PHONE NUMBER: \(result.phone ?? "")")
                .font(.custom("Verlag-Bold", size: 15))
                .foregroundColor(Color.showCodeText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 5)
        }
        .padding(10)
        .background(isTapped ? Color.black.opacity(0.2) : Color.white)
        .animation(.easeInOut(duration: 0.2), value: isTapped)
        .onTapGesture {
            isTapped = true
            onCellTapped(result.orderId ?? 0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isTapped = false
            }
        }
    }
}
