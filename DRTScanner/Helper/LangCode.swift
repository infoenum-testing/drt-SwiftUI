//
//  LangCode.swift
//  DRTScanner
//
//  Created by IE15 on 05/08/25.
//

import Foundation

// Languages you know about
enum LangCode: String {
    case enUS = "en_US"
    case frCA = "fr_CA"
    case esUS = "es_US"
    
    static func currentLangCode() -> String {
        let locale = Locale.current
        
        let languageCode = locale.language.languageCode?.identifier ?? "en"
        let regionCode = locale.region?.identifier ?? "US"
        
        return "\(languageCode)_\(regionCode)"
    }
}
