//
//  AppStringsModel.swift
//  DRTScanner
//
//  Created by IE15 on 05/08/25.
//


import Foundation

struct AppStringsModel: Codable {
    
    let enUS: SelectedLangStrings
    let frCA: SelectedLangStrings
    let esUS: SelectedLangStrings
    
    enum CodingKeys: String, CodingKey {
        case enUS = "en_US"
        case frCA = "fr_CA"
        case esUS = "es_US"
    }
}

extension AppStringsModel {
    /// Fetch by exact language code
    subscript(_ code: LangCode) -> SelectedLangStrings {
        switch code {
        case .enUS: return enUS
        case .frCA: return frCA
        case .esUS: return esUS
        }
    }
    
    /// Overload that also accepts the raw string ("en_US") and returns nil if unknown
    subscript(_ raw: String) -> SelectedLangStrings? {
        LangCode(rawValue: raw).map { self[$0] }
    }
}
