//
//  ColorManger.swift
//  DRTScanner
//
//  Created by IE15 on 15/07/25.
//

import Foundation
import SwiftUICore

final class ColorManager {

    static let shared = ColorManager()

     var skin: SkinModel?

    func updateSkin(to newSkin: SkinModel) {
        self.skin = newSkin
    }
}

