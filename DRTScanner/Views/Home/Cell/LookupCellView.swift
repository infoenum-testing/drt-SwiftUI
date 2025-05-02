//
//  LookupCellView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 18/02/25.
//

import SwiftUI

/// A view that displays order lookup information in a tappable cell.
/// Shows buyer name, order ID, CC, and phone number.
/// Briefly highlights when tapped and triggers a callback with the order ID.
struct LookupCellView: View {
    var result: OrdersNewApi
    var onCellTapped: (Int) -> Void
    @State private var isTapped = false
    
    var body: some View {
        VStack(alignment: .center) {
            Text(result.buyerName ?? "")
                .font(.verlagBlackAdaptive(size: 24))
                .foregroundColor(Color.customGreen)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 0)
            
            HStack {
                
                Text("\(StringConstants.LandingView.orderLabel): \(result.orderId ?? 0)")
                    .font(.verlagBoldAdaptive(size: 15))
                    .foregroundColor(Color.customGreen)
                
                Text("\(StringConstants.LandingView.ccLabel): \(result.cc ?? "")")
                    .font(.verlagBoldAdaptive(size: 15))
                    .foregroundColor(Color.customGreen)
            }
            .padding(.top, 1)
            
            Text("\(StringConstants.LandingView.phoneLabel): \(result.phone ?? "")")
                .font(.verlagBoldAdaptive(size: 15))
                .foregroundColor(Color.customGreen)
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
