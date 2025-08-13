//
//  AppLogoView.swift
//  DRTScanner
//
//  Created by IE15 on 17/07/25.
//
import SwiftUI

struct AppLogoView: View {
    let width:CGFloat
    let height:CGFloat
    @State private var Loading:Bool = true
    @EnvironmentObject var stringManager: StringManager
    var body: some View {
        ZStack {

                if let url = URL(string: stringManager.strings.appLogoSvg) {
                  
                        SVGWebView(url: url, isLoading: $Loading)
                            .scaledToFill()
                            .clipped()
                            .frame(width: width, height: height)
                    .overlay {
                        if Loading {
                            Image(StringConstants.DRTImages.logo)
                                .resizable()
                                .scaledToFit()
                                .clipped()
                                .frame(width: width, height: height)
                                .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: Loading)}
                    }
                }
        }
        .clipped()
        .frame(width: width, height: height)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: Loading)
    }
}
