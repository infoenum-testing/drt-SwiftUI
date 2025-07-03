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
        HStack(alignment: .center) {
            // Left content
            VStack(alignment: .leading, spacing: 6) {
                Text(result.buyerName ?? "")
                    .font(.verlagBlackAdaptive(size: 24))
                    .foregroundColor(Color.customGreen)

                HStack(spacing: 12) {
                    Text("\(stringManager.strings?.searchResults.order ?? StringConstants.LandingView.orderLabel): \(String(result.orderId ?? 0))")
                    Text("\(stringManager.strings?.searchResults.cc ?? StringConstants.LandingView.ccLabel) \(result.cc ?? "")")
                }
                .font(.verlagBoldAdaptive(size: 15))
                .foregroundColor(Color.customGreen)

                Text("\(stringManager.strings?.searchResults.phoneNumber ?? StringConstants.LandingView.phoneLabel) \(result.phone ?? "")")
                    .font(.verlagBoldAdaptive(size: 15))
                    .foregroundColor(Color.customGreen)
            }

            Spacer()

            // Right arrow
            Image(StringConstants.SeatHomeView.rightSideArrow)
                .resizable()
                .scaledToFit()
                .frame(width: 15.adaptiveForIpad, height: 20.adaptiveForIpad)
        }
        .padding([.leading, .top, .trailing])
        .padding(.bottom, 5)
        .background(isTapped ? Color.black.opacity(0.1) : Color.white)
        .shadow(color: isTapped ? Color.black.opacity(0.05) : Color.clear, radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.2), value: isTapped)
        .onTapGesture {
            isTapped = true
            onCellTapped(result.orderId ?? 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isTapped = false
            }
        }
        Divider()
        }.edgesIgnoringSafeArea(.leading)
    }
}
