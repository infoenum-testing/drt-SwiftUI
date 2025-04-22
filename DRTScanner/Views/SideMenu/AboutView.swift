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
                            .frame(width: 25, height: 25)
                            .background(Color.clear)
                            .contentShape(Rectangle())
                            .foregroundColor(.black)
                            .padding()
                    }
                }.padding(.top, 0)
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                VStack {
                    Text("Our purpose and mission is to provide small bussinesses with the advantages to grow and prosper through innovative solution and lifelong relationships.")
                        .font(.custom(StringConstants.DRTFont.verlagBold, size: 16))
                        .foregroundColor(Color.customWhite)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text(AboutView.urlString)
                            .underline()
                            .foregroundColor(.white)
                            .font(.custom(StringConstants.DRTFont.verlagBold, size: 20))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.FFCE_62)
                            .cornerRadius(12)
                            .onTapGesture {
                                showWebsiteAlert = true
                            }
                            .alert(isPresented: $showWebsiteAlert) {
                                Alert(
                                    title: Text("Open DRT Website?"),
                                    message: Text("Do you want to visit the DRT website?"),
                                    primaryButton: .default(Text("Yes")) {
                                        openWebsite()
                                    },
                                    secondaryButton: .cancel(Text("No"))
                                )
                            }
                            .padding()
                    
                    Text("Copyright(c) 2013-2025. DRT Performance Tix.")
                        .font(.custom(StringConstants.DRTFont.verlagBold, size: 18))
                        .foregroundColor(Color.customWhite)
                        .multilineTextAlignment(.center)
                    
                    Text("All Rights Reserved")
                        .font(.custom(StringConstants.DRTFont.verlagBold, size: 18))
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
