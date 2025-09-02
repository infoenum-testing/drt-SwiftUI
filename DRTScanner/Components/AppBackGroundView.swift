//
//  AppBackGroundView.swift
//  DRTScanner
//
//  Created by IE15 on 16/07/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct AppBackGroundView: View {
    var width:     CGFloat? = nil
    var height:    CGFloat? = nil
    var maxWidth:  CGFloat? = nil
    var maxHeight: CGFloat? = nil
    var shadow: Bool = false
    @State private var shouldShowPlaceHolder: Bool = true
    @EnvironmentObject var stringManager: StringManager

    var body: some View {
        ZStack(alignment: .top) {
            if let url = URL(string: stringManager.strings.backImageSvg) {
                WebImage(url: url)
                    // attach callbacks **before** other modifiers
                    .onSuccess { _, _, _ in
                        DispatchQueue.main.async {
                            shouldShowPlaceHolder = false
                        }
                    }
                    .onFailure { error in
                        print("Failed to load background: \(error.localizedDescription)")
                    }
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: width, height: height)
                    .frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    .overlay {
                        if shouldShowPlaceHolder {
                            Image(StringConstants.DRTImages.backgound)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                        }
                        if shadow {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0.3), .clear]),
                                startPoint: .top,
                                endPoint: .center
                            )
                        }
                    }
                    .transition(.opacity)
            }
        }
        .clipped()
        .frame(width: width, height: height)
        .frame(maxWidth: maxWidth, maxHeight: maxHeight)
    }
}
