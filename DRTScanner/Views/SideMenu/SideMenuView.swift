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
        ZStack (alignment: .trailing){
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            VStack(alignment: .trailing) {
                Button(action: { isPresented = false }) {
                    Image("Popup_cross_btn")
                        .padding()
                }.padding(.top, 50)
                
                VStack(alignment: .leading, spacing: 20) {
                    SideMenuOption(title: "GO OFFLINE")
                    SideMenuOption(title: "SCANNING STATS")
                    SideMenuOption(title: "ABOUT")
                    SideMenuOption(title: "STOP SCANNING")
                    SideMenuOption(title: "DRT WEBSITE")
                    SideMenuOption(title: "SETTINGS")
                }
                .padding()
                
                Spacer()
            }
            .frame(width: 250)
            .background(.showCodeButton)
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
