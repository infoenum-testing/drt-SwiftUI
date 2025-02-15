//
//  Font..swift
//  DRTScanner
//
//  Created by IE Mac 05 on 31/01/25.
//


import SwiftUI

extension Font {
    static func verlagBook(size: CGFloat) -> Font {
        return Font.custom("Verlag-Book", size: size)
    }
    
    static func verlagBold(size: CGFloat) -> Font {
        return Font.custom("Verlag-Bold", size: size)
    }
    
    static func verlagBlack(size: CGFloat) -> Font {
        return Font.custom("Verlag-Black", size: size)
    }
}
