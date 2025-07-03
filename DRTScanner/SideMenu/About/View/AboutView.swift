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
    static let urlString = "www.Drttix.com"
    @EnvironmentObject var stringManager: StringManager
    
    var body: some View {
        ZStack {
            Image(StringConstants.DRTImages.backgound)
                .resizable()
                .scaledToFill()
                .frame(height: UIScreen.main.bounds.height * 0.65)
                .frame(maxWidth: .infinity)
                .clipped()
                .edgesIgnoringSafeArea(.top)
           
            VStack(spacing: 20) {
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
                            .padding(.trailing)
                    }
                }.padding(.top)
                Image(StringConstants.DRTImages.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120.adaptiveForIpad)
                VStack {
                    Text(stringManager.strings?.mission ?? StringConstants.SideMenuView.aboutDescriptionText)
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
                                    title: Text(stringManager.strings?.dialogOpenBrowser.description ?? StringConstants.SideMenuView.openDrtWebsiteMessage)
                                        .font(UIDevice.current.userInterfaceIdiom == .pad ? .title : .headline),
                                    message: Text("")
                                        .font(UIDevice.current.userInterfaceIdiom == .pad ? .title3 : .subheadline),
                                    primaryButton: .default(Text("OPEN")) {
                                        openWebsite()
                                    },
                                    secondaryButton: .cancel(Text("CANCEL"))
                                )
                            }
                            .padding()
                    
                    Text(stringManager.strings?.copyright.replacingOccurrences(of: ". All", with: ".\n All") ?? StringConstants.LandingView.copyRight)
                        .font(.verlagBookAdaptive(size: 14))
                        .foregroundColor(Color.customWhite)
                        .multilineTextAlignment(.center)
                        .frame(height: 40.adaptiveForIpad)
                    
                }
               
                .padding(.bottom)
            }
        }.frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 1.7)
            .ignoresSafeArea(.all)
    }
    
    func openWebsite() {
        if let url = URL(string: stringManager.strings?.serviceHref ?? "http://www.dancerecitalticketing.com") {
            UIApplication.shared.open(url)
        }
    }
}
