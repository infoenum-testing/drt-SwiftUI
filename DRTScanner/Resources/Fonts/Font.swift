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

extension Font {
    static func verlagBookAdaptive(size: CGFloat) -> Font {
        let finalSize = adaptiveFontSize(for: size)
        return .verlagBook(size: finalSize)
    }
    
    static func verlagBoldAdaptive(size: CGFloat) -> Font {
        let finalSize = adaptiveFontSize(for: size)
        return .verlagBold(size: finalSize)
    }
    
    static func pickerBoldText(size: CGFloat) -> Font {
        let finalSize = pickerText(for: size)
        return .verlagBold(size: finalSize)
    }
    
    static func verlagBlackAdaptive(size: CGFloat) -> Font {
        let finalSize = adaptiveFontSize(for: size)
        return .verlagBlack(size: finalSize)
    }
    
    private static func adaptiveFontSize(for baseSize: CGFloat) -> CGFloat {
        if UIDevice.isIpad {
            return UIDevice.isLandscape ? baseSize * 1.5 : baseSize * 2
        } else {
            return baseSize
        }
    }
    
    private static func pickerText(for baseSize: CGFloat) -> CGFloat {
        if UIDevice.isIpad {
            return  baseSize * 1.5
        } else {
            return baseSize
        }
    }
    
}

extension UIDevice {
    static var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isLandscape: Bool {
        return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape ?? false
    }
}

extension BinaryInteger {
    var adaptiveForIpad: CGFloat {
        let value = CGFloat(self)
        return UIDevice.isIpad ? value * 2 : value
    }
}

extension CGFloat {
    var adaptiveForIpadScan: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? self * 1 : self
    }
}

func topPaddingForDevice() -> CGFloat {
    let nativeHeight = UIScreen.main.nativeBounds.height
    
    
    switch nativeHeight {
    case 2732:
        // iPad Pro 12.9" (3rd, 4th, 5th, 6th gen), iPad Pro 13" M4
        return UIScreen.main.bounds.height * 0.13
    case 2360:
        // iPad Air 4th/5th gen, iPad 10th gen
        return UIScreen.main.bounds.height * 0.15
    case 2266:
        // iPad mini 6th gen
        return UIScreen.main.bounds.height * 0.16
    default:
        // Unknown iPad, use a safe fallback
        return UIScreen.main.bounds.height * 0.13
    }
}

func scannerTopPadding(isFullScreen: Bool) -> CGFloat {
    guard UIDevice.current.userInterfaceIdiom == .pad, !isFullScreen else {
        return 0
    }
    
    let nativeHeight = UIScreen.main.nativeBounds.height
    
    switch nativeHeight {
    case 2732:
        // iPad Pro 12.9" or 13" M4
        return 120
    case 2360:
        // iPad 10th gen, iPad Air 4th/5th gen
        return 80
    case 2266:
        // iPad mini 6th gen
        return 70
    default:
        // Default padding for other iPads
        return 120
    }
}

import SwiftUI

func topSafeAreaPadding() -> CGFloat {
    let window = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }
    
    let topInset = window?.safeAreaInsets.top ?? 0
    
    return topInset
}

import SwiftUI

func topSafeAreaPaddingHeader() -> CGFloat {
    let screenHeight = UIScreen.main.bounds.height
    let window = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }
    
    let topInset = window?.safeAreaInsets.top ?? 0
    if screenHeight <= 667 {
        return 15
    }
    
    return topInset
}

func resultSheetHeightForIphone() -> CGFloat {
    return UIScreen.main.bounds.height
        - (115.adaptiveForIpad + topSafeAreaPaddingHeader())
        - (UIScreen.main.bounds.height / 3)
}

func resultSheetHeightForIpad() -> CGFloat {
    return UIScreen.main.bounds.height
        - (100.adaptiveForIpad + topSafeAreaPaddingHeader())
        - (UIScreen.main.bounds.height / 3)
}



func calculatedTopPadding() -> CGFloat {
    let device = UIDevice.current.userInterfaceIdiom
    let screenHeight = UIScreen.main.bounds.height
    let safeTop = topSafeAreaPadding()
    
    if device == .pad {
        return safeTop + (UIDevice.isLandscape ? 120 : 180)
    } else if screenHeight <= 667 {
        // iPhone SE 2nd gen, iPhone 8, iPhone 6/7
        return safeTop + 90
    } else {
        // All other regular iPhones (e.g., 11, 12, 13, 14...)
        return safeTop + 100
    }
}

func calculatedBottomPadding() -> CGFloat {
    let device = UIDevice.current.userInterfaceIdiom
    let screenHeight = UIScreen.main.bounds.height
    let safeTop = topSafeAreaPadding()
    
    if device == .pad {
        return safeTop + (UIDevice.isLandscape ? screenHeight * 2.2 : screenHeight * 0.75)
    } else if screenHeight <= 667 {
        // iPhone SE 2nd gen, iPhone 8, iPhone 6/7
        return screenHeight * 0.35
    } else {
        // All other regular iPhones (e.g., 11, 12, 13, 14...)
        return screenHeight * 0.2
    }
}
