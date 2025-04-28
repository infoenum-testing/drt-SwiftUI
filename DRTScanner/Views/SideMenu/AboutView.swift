//
//  AboutView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//


import SwiftUI

struct AboutView: View {
    @Binding var isPresented: Bool
    @State private var showWebsiteAlert = false
    static let urlString = "www.drttix.com"
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
                        Image(StringConstants.DRTImages.crossImage)
                            .resizable()
                            .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                            .background(Color.clear)
                            .contentShape(Rectangle())
                            .foregroundColor(.black)
                            .padding()
                    }
                }.padding(.top)
                Image(StringConstants.DRTImages.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150.adaptiveForIpad)
                VStack {
                    Text("Our purpose and mission is to provide small bussinesses with the advantages to grow and prosper through innovative solution and lifelong relationships.")
                        .font(.verlagBoldAdaptive(size: 16))
                        .foregroundColor(Color.customWhite)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil) // ← Allows unlimited lines
                        .fixedSize(horizontal: false, vertical: true) // ← Allows wrapping
                        .padding(.horizontal)
                    
                    Text(AboutView.urlString)
                            .foregroundColor(.white)
                            .font(.verlagBoldAdaptive(size: 30))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.FFCE_62)
                            .cornerRadius(12)
                            .onTapGesture {
                                showWebsiteAlert = true
                            }
                            .alert(isPresented: $showWebsiteAlert) {
                                Alert(
                                    title: Text("Open DRT Website?")
                                        .font(UIDevice.current.userInterfaceIdiom == .pad ? .title : .headline),
                                    message: Text("Do you want to visit the DRT website?")
                                        .font(UIDevice.current.userInterfaceIdiom == .pad ? .title3 : .subheadline),
                                    primaryButton: .default(Text("Yes")) {
                                        openWebsite()
                                    },
                                    secondaryButton: .cancel(Text("No"))
                                )
                            }
                            .padding()
                    
                    Text("Copyright(c) 2013-2025. DRT Performance Tix.")
                        .font(.verlagBookAdaptive(size: 14))
                        .foregroundColor(Color.customWhite)
                        .multilineTextAlignment(.center)
                    
                    Text("All Rights Reserved")
                        .font(.verlagBookAdaptive(size: 14))
                        .foregroundColor(Color.customWhite)
                        .multilineTextAlignment(.center)
                    
                }
               
                .padding(.bottom)
            }
        }.frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 1.7)
            .ignoresSafeArea(.all)
    }
    
    func openWebsite() {
        if let url = URL(string: "http://www.dancerecitalticketing.com") {
            UIApplication.shared.open(url)
        }
    }
}
