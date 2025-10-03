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
    let height = UIDevice.current.userInterfaceIdiom == .pad ? UIDevice.isLandscape ? 0.6 : 0.5 : 0.5
    @State var shouldShowLogo: Bool = false
    var body: some View {
        ZStack(alignment: .top) {
            // Background image
            AppBackGroundView(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height * height,shadow: true)
            
            // Main content
            VStack(spacing: 20) {
                Spacer()// Leave space for the close button
                if shouldShowLogo {
                    AppLogoView(width: 120.adaptiveForIpad, height: 65.adaptiveForIpad)
                        .scaleEffect(shouldShowLogo ? 1.0 : 0.95)
                        .animation(.easeInOut(duration: 0.4), value: shouldShowLogo)
                } else {
                    VStack{}
                        .frame(width:  120.adaptiveForIpad, height: 65.adaptiveForIpad)
                        .foregroundColor(.clear)
                }
                VStack(spacing: 16) {
                    Text(stringManager.strings.mission)
                        .font(.verlagBoldAdaptive(size: 16))
                        .foregroundColor(Color.primaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                    
                    Text(stringManager.strings.serviceHref)
                        .foregroundColor(Color.primaryText)
                        .font(.verlagBoldAdaptive(size: 30))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.secondaryBg)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 5)
                        .onTapGesture {
                            showWebsiteAlert = true
                        }
                        .alert(isPresented: $showWebsiteAlert) {
                            Alert(
                                title: Text(stringManager.strings.dialogOpenBrowser.description),
                                message: Text(""),
                                primaryButton: .default(Text(stringManager.strings.dialogOpenBrowser.continueField)) { openWebsite() },
                                secondaryButton: .cancel(Text(stringManager.strings.dialogOpenBrowser.cancel))
                            )
                        }
                    
                    Text(stringManager.strings.copyright
                        .replacingOccurrences(of: ". All", with: ".\n All")
                    )
                    .font(.verlagBookAdaptive(size: 14))
                    .foregroundColor(Color.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(height: 40.adaptiveForIpad)
                }
                .padding(.horizontal,15.adaptiveForIpad)
                Spacer()
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
            .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 50 : topSafeAreaPaddingHeader())
        }
        .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height * height)
        .onAppear {
            Task {
                
            }
            Task {
                try? await Task.sleep(nanoseconds: 400_000_000) // 0.3 sec
                shouldShowLogo = true
            }
        }
    }
    
    func openWebsite() {
        let urlString = stringManager.strings.serviceHref
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
