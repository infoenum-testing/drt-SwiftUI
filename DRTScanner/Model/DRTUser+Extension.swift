//
//  DRTUser+Exr.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/02/25.
//

import Foundation

extension DRTUser {

    static func saveToDefaults(user: DRTUser) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }

    static func getCurrentUser() -> DRTUser? {
        if let savedUserData = UserDefaults.standard.data(forKey: "currentUser"),
           let decodedUser = try? JSONDecoder().decode(DRTUser.self, from: savedUserData) {
            return decodedUser
        }
        return nil
    }
}
