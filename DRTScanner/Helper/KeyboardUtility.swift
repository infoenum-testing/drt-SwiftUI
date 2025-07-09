//
//  KeyboardUtility.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 07/07/25.
//


import SwiftUI
import Foundation
extension View {
  func hideKeyboardOnTap() -> some View {
    self.onTapGesture {
      KeyboardUtility.hideKeyboard()
    }
  }
}
struct KeyboardUtility {
  static func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
