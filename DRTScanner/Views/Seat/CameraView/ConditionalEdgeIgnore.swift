//
//  ConditionalEdgeIgnore.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 04/04/25.
//

import SwiftUI

struct ConditionalEdgeIgnore: ViewModifier {
    var isFullScreen: Bool
    
    func body(content: Content) -> some View {
        if isFullScreen {
            content.edgesIgnoringSafeArea(.top)
        } else {
            content
        }
    }
}
