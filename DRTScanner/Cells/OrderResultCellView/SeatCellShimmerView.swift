//
//  SeatCellShimmerView.swift
//  DRTScanner
//
//  Created by DRT on 24/09/25.
//

import SwiftUI
import Shimmer

struct SeatCellShimmerView: View {
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
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
                ZStack {
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
                }
                .padding(.vertical)
                .frame(width:UIScreen.main.bounds.width*0.20)
                .background(Color.primaryText)
                
            }
            .background(Color.primaryText)
            .padding([.leading, .top])
            .padding(.bottom, 5)
            Divider()
        }
        .edgesIgnoringSafeArea(.leading)
    }
}

#Preview {
    SeatCellShimmerView()
}
