//
//  AboutView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//


import SwiftUI

struct AboutView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
               // .scaledToFit()
           
            VStack(spacing: 20) {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }) {
                        Image("Popup_cross_btn")
                            .foregroundColor(.black)
                            .padding()
                    }
                }.padding(.top, 0)
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                Spacer()
                
                Text("Copyright(c) 2013-2025. DRT Performance Tix.")
                    .font(.custom("Verlag-Bold", size: 20))
                    .foregroundColor(Color.customWhite)
                    .multilineTextAlignment(.center)
                
                Text("All Rights Reserved")
                    .font(.custom("Verlag-Bold", size: 20))
                    .foregroundColor(Color.customWhite)
                    .multilineTextAlignment(.center)
                
                
                Link(destination: URL(string: "http://www.dancerecitalticketing.com")!) {
                    Text("http://www.dancerecitalticketing.com")
                        .underline()
                        .font(.custom("Verlag-Bold", size: 20))
                        .tint(Color.customWhite)
                }.buttonStyle(PlainButtonStyle())
                .padding(.bottom, 50)
            }
        }.frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 1.7)
            .ignoresSafeArea(.all)
    }
}
