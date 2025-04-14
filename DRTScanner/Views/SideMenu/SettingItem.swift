//
//  SettingItem.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/04/25.
//

import SwiftUI

struct SettingItem: Hashable {
    var title: String
    var toggleBinding: Binding<Bool>? = nil
    var value: String? = nil

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: SettingItem, rhs: SettingItem) -> Bool {
        lhs.title == rhs.title
    }
}
