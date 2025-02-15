//
//  KeychainManager.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.
//

import Foundation
import KeychainSwift

struct KeychainManager {
        
    private static let keychain = KeychainSwift()
    
 
    static func saveToken(_ token: String) {
        keychain.set(token, forKey: StringConstants.Common.token)
    }
    
    static func getToken() -> String? {
        return keychain.get(StringConstants.Common.token)
    }
    static func removeToken(){
        keychain.delete(StringConstants.Common.token)
    }
    
    static func saveRefreshToken(_ refreshToken: String) {
        keychain.set(refreshToken, forKey: StringConstants.Common.refreshToken)
    }
    
    static func getRefreshToken() -> String? {
        return keychain.get(StringConstants.Common.refreshToken)
    }

    
}
