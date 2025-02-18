//
//  SideMenuView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 10/02/25.
//

import SwiftUI
import Foundation

struct SideMenuView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack(alignment: .trailing) {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                isPresented = false
                            }
                        }

                    VStack(alignment: .trailing) {
                        Spacer().frame(height: 50)

                        Button(action: { isPresented = false }) {
                            Image("Popup_cross_btn")
                                .padding()
                        }

                        VStack(alignment: .leading, spacing: 20) {
                            SideMenuOption(title: StringConstants.SideMenuView.goOffline)
                            SideMenuOption(title: StringConstants.SideMenuView.scaningStats)
                            SideMenuOption(title: StringConstants.SideMenuView.about)
                            SideMenuOption(title: StringConstants.SideMenuView.stopScanning)
                            SideMenuOption(title: StringConstants.SideMenuView.drtWebsite)
                            SideMenuOption(title: StringConstants.SideMenuView.setting)
                        }
                        .padding()

                        Spacer() // Pushes menu items to the top
                    }
                    .frame(width: 250, height: UIScreen.main.bounds.height) // Ensures it covers full height
                    .background(Color.showCodeButton)
                    .edgesIgnoringSafeArea(.all)
                }
    }
}

struct SideMenuOption: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(Font.custom("Verlag-Bold", size: 20))
                .foregroundColor(.customWhite)
                 Spacer()
        }
        .padding()
    }
}
