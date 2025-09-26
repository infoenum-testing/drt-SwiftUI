//
//  MerchandiseOrderShimmerView.swift
//  DRTScanner
//
//  Created by DRT on 24/09/25.
//

import SwiftUI
import Shimmer

struct MerchandiseOrderShimmerView: View {
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                VStack {
                    Circle()
                        .fill(Color.neutralText.opacity(0.2))
                        .frame(width: 70.adaptiveForIpad, height: 70.adaptiveForIpad)
                        .listRowBackground(Color.primaryText)
                        .shimmering( active: true,
                                     gradient: Gradient(colors: [ Color.primaryText.opacity(0.5),
                                                                  Color.primaryText,
                                                                  Color.primaryText.opacity(0.5)])
                        )
                }
                
                HStack(alignment: .center, spacing: 5) {
                    // Display merchandise name and variant
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.neutralText.opacity(0.2))
                        .frame(width: 100.adaptiveForIpad, height: 20.adaptiveForIpad)
                        .listRowBackground(Color.primaryText)
                        .shimmering( active: true,
                                     gradient: Gradient(colors: [ Color.primaryText.opacity(0.5),
                                                                  Color.primaryText,
                                                                  Color.primaryText.opacity(0.5)])
                        )
                    Spacer()
                }
                
                Spacer()
                
                // Scan button and status
                Circle()
                    .fill(Color.neutralText.opacity(0.2))
                    .frame(width: 30.adaptiveForIpad, height: 30.adaptiveForIpad)
                    .listRowBackground(Color.primaryText)
                    .shimmering( active: true,
                                 gradient: Gradient(colors: [ Color.primaryText.opacity(0.5),
                                                              Color.primaryText,
                                                              Color.primaryText.opacity(0.5)])
                    )
                    .padding(.trailing, 10)
            }
            .frame(height: 130.adaptiveForIpad)
            Rectangle()
                .fill(Color.colorButtonText)
                .frame(width: UIScreen.main.bounds.width, height: 1)
        }
    }
}

#Preview {
    MerchandiseOrderShimmerView()
}
