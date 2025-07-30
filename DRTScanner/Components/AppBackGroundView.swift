//
//  AppBackGroundView.swift
//  DRTScanner
//
//  Created by IE15 on 16/07/25.
//

import SwiftUI

struct AppBackGroundView: View {
    var width:     CGFloat? = nil
    var height:    CGFloat? = nil
    var maxWidth:  CGFloat? = nil
    var maxHeight: CGFloat? = nil
    var shadow: Bool = false
    @EnvironmentObject var stringManager: StringManager
    @State private var Loading:Bool = true
    var body: some View {
        ZStack(alignment: .top) {
            if let backImage = stringManager.strings?.backImageSvg {
                if let url = URL(string: backImage) {
                    SVGWebView(url: url, isLoading: $Loading)
                        .scaledToFill()
                        .clipped()
                        .frame(width:  width,
                               height: height)
                        .frame(maxWidth:  maxWidth,
                               maxHeight: maxHeight)
                    
                        .overlay {
                            if Loading {
                                Image(StringConstants.DRTImages.backgound)
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                                    .frame(width:  width,
                                           height: height)
                                    .frame(maxWidth:  maxWidth,
                                           maxHeight: maxHeight)
                                    .transition(.opacity)
                                    .animation(.easeInOut(duration: 0.3), value: Loading)
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
                        .animation(.easeInOut(duration: 0.3), value: Loading)
                }
            } else {
                Image(StringConstants.DRTImages.backgound)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: width, height: height)
                    .frame(maxWidth:  maxWidth,
                           maxHeight: maxHeight)
                    .overlay {
                        if shadow {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0.3), .clear]),
                                startPoint: .top,
                                endPoint: .center
                            )
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: Loading)
            }
        }
        .clipped()
        .frame(width:  width,
               height: height)
        .frame(maxWidth:  maxWidth,
               maxHeight: maxHeight)
    }
}


