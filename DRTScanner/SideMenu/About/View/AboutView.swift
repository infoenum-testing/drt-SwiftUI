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
        ZStack(alignment: .top) {
            // Background image
            Image(StringConstants.DRTImages.backgound)
                .resizable()
                .scaledToFill()
                .frame(height: UIScreen.main.bounds.height * 0.65)
                .frame(maxWidth: .infinity)
                .clipped()
                .ignoresSafeArea(edges: .top)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.3), .clear]),
                        startPoint: .top,
                        endPoint: .center
                    )
                )

            // Main content
            VStack(spacing: 20) {
                Spacer().frame(height: 60) // Leave space for the close button
                Image(StringConstants.DRTImages.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120.adaptiveForIpad)

                VStack(spacing: 16) {
                    Text(stringManager.strings?.mission ?? StringConstants.SideMenuView.aboutDescriptionText)
                        .font(.verlagBoldAdaptive(size: 16))
                        .foregroundColor(Color.customWhite)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)

                    Text(stringManager.strings?.serviceHref ?? AboutView.urlString)
                    .foregroundColor(.white)
                    .font(.verlagBoldAdaptive(size: 30))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.FFCE_62)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 5)
                    .onTapGesture {
                        showWebsiteAlert = true
                    }
                    .alert(isPresented: $showWebsiteAlert) {
                        Alert(
                            title: Text(stringManager.strings?.dialogOpenBrowser.description ?? StringConstants.SideMenuView.openDrtWebsiteMessage),
                            message: Text(""),
                            primaryButton: .default(Text("OPEN")) { openWebsite() },
                            secondaryButton: .cancel(Text("CANCEL"))
                        )
                    }

                    Text(stringManager.strings?.copyright
                        .replacingOccurrences(of: ". All", with: ".\n All")
                          ?? StringConstants.LandingView.copyRight
                    )
                    .font(.verlagBookAdaptive(size: 14))
                    .foregroundColor(Color.customWhite)
                    .multilineTextAlignment(.center)
                    .frame(height: 40.adaptiveForIpad)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }

            // Close Button (X)
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
                        .padding()
                }
            }
            .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30)
        }
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 1.7)
    }

    func openWebsite() {
        let urlString = stringManager.strings?.serviceHref ?? "https://www.drttix.com"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
