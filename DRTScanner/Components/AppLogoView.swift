//
//  AppLogoView.swift
//  DRTScanner
//
//  Created by IE15 on 17/07/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct AppLogoView: View {
    let width: CGFloat
    let height: CGFloat
    @State private var url: String = ""
    @State private var shouldShowLogo: Bool = true
    @EnvironmentObject var stringManager: StringManager
    
    var body: some View {
        ZStack {
            if let url = URL(string: url) {
                WebImage(url: url, options: [.retryFailed])
                    .onSuccess { _, _, _ in
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                shouldShowLogo = false
                            }
                        }
                    }
                    .onFailure { error in
                        print("⚠️ Logo load failed: \(error.localizedDescription)")
                     
                    }
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .frame(width: width, height: height)
            }
            
            else if shouldShowLogo {
                Image(StringConstants.DRTImages.logo)
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .frame(width: width, height: height)
                    .transition(.opacity)
            }
        }
        .frame(width: width, height: height)
        .animation(.easeInOut(duration: 0.3), value: shouldShowLogo)
        .onAppear {
            if !String.logoHref.isEmpty  {
                url = String.logoHref
            } else {
                url = stringManager.strings.appLogoSvg
            }
        }
    }
}
