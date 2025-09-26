//
//  LookUpCellShimmerView.swift
//  DRTScanner
//
//  Created by DRT on 24/09/25.
//

import SwiftUI
import Shimmer

struct LookUpCellShimmerView: View {
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                // Left content
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.neutralText.opacity(0.2))
                        .frame(width: 150.adaptiveForIpad, height: 20.adaptiveForIpad)
                        .listRowBackground(Color.primaryText)
                        .shimmering(
                            active: true,
                            gradient: Gradient(colors: [
                                Color.primaryText.opacity(0.5),
                                Color.primaryText,
                                Color.primaryText.opacity(0.5)
                            ])
                        )
                    
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.neutralText.opacity(0.2))
                        .frame(width: 150.adaptiveForIpad, height: 20.adaptiveForIpad)
                        .listRowBackground(Color.primaryText)
                        .shimmering(
                            active: true,
                            gradient: Gradient(colors: [
                                Color.primaryText.opacity(0.5),
                                Color.primaryText,
                                Color.primaryText.opacity(0.5)
                            ])
                        )
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.neutralText.opacity(0.2))
                        .frame(width: 150.adaptiveForIpad, height: 20.adaptiveForIpad)
                        .listRowBackground(Color.primaryText)
                        .shimmering(
                            active: true,
                            gradient: Gradient(colors: [
                                Color.primaryText.opacity(0.5),
                                Color.primaryText,
                                Color.primaryText.opacity(0.5)
                            ])
                        )
                }
                
                Spacer()
                
                // Right arrow
                Circle()
                    .fill(Color.neutralText.opacity(0.2))
                    .frame(width: 30.adaptiveForIpad, height: 30.adaptiveForIpad)
                    .listRowBackground(Color.primaryText)
                    .shimmering(
                        active: true,
                        gradient: Gradient(colors: [
                            Color.primaryText.opacity(0.5),
                            Color.primaryText,
                            Color.primaryText.opacity(0.5)
                        ])
                    )
                    .frame(width: 15.adaptiveForIpad, height: 20.adaptiveForIpad)
            }
            .padding([.leading, .top, .trailing])
            .padding(.bottom, 5)
            .background( Color.primaryText)
            .shadow(color: Color.clear, radius: 4, x: 0, y: 2)
            Divider()
        }.edgesIgnoringSafeArea(.leading)
    }
}

#Preview {
    LookUpCellShimmerView()
}
