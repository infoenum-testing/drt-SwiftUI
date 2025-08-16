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
    @EnvironmentObject var stringManager: StringManager
    
    var body: some View {
        VStack {
            Button {
                isTapped = true
                onCellTapped(result.orderId ?? 0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isTapped = false
                }
            } label: {
                HStack(alignment: .center) {
                    // Left content
                    VStack(alignment: .leading, spacing: 6) {
                        CustomsText(title: result.buyerName ?? "", textFont: .verlagBlackAdaptive(size: 24), foregroundColour: .primaryBg)
                     
                        
                        HStack(spacing: 12) {
                            CustomsText(title: "\(stringManager.strings.searchResults.order): \(String(result.orderId ?? 0))", textFont: .verlagBoldAdaptive(size: 15), foregroundColour: .primaryBg)
                            CustomsText(title: "\(stringManager.strings.searchResults.cc) \(result.cc ?? "")", textFont: .verlagBoldAdaptive(size: 15), foregroundColour: .primaryBg)
                        
                        }
                        CustomsText(title: "\(stringManager.strings.searchResults.phoneNumber) \(result.phone ?? "")", textFont: .verlagBoldAdaptive(size: 15), foregroundColour: .primaryBg)
                    }
                    
                    Spacer()
                    
                    // Right arrow
                    Image(StringConstants.SeatHomeView.rightSideArrow)
                        .resizable()
                        .foregroundColor(Color.neutralText)
                        .scaledToFit()
                        .frame(width: 15.adaptiveForIpad, height: 20.adaptiveForIpad)
                }
                .padding([.leading, .top, .trailing])
                .padding(.bottom, 5)
                .background(isTapped ? Color.black.opacity(0.1) : Color.primaryText)
                .shadow(color: isTapped ? Color.black.opacity(0.05) : Color.clear, radius: 4, x: 0, y: 2)
                .animation(.easeInOut(duration: 0.2), value: isTapped)
            }
            
            Divider()
        }.edgesIgnoringSafeArea(.leading)
    }
}
