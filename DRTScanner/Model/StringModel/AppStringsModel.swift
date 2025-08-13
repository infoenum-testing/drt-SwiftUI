//
//  AppStringsModel.swift
//  DRTScanner
//
//  Created by IE15 on 05/08/25.
//

import Foundation

/// A dynamic model that can hold any number of languages from JSON
struct AppStringsModel: Codable {
    var languages: [String: SelectedLangStrings]

    init(languages: [String: SelectedLangStrings]) {
        self.languages = languages
    }

    // MARK: - Dynamic Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var tempLanguages: [String: SelectedLangStrings] = [:]

        for key in container.allKeys {
            let value = try container.decode(SelectedLangStrings.self, forKey: key)
            tempLanguages[key.stringValue] = value
        }

        self.languages = tempLanguages
    }

    // MARK: - Dynamic Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)
        for (key, value) in languages {
            guard let codingKey = DynamicCodingKeys(stringValue: key) else { continue }
            try container.encode(value, forKey: codingKey)
        }
    }

    // MARK: - Access by Code
    subscript(code: String) -> SelectedLangStrings? {
        return languages[code]
    }

    // Get system default code from Locale
    static func getSystemLangCode() -> String {
        let preferredLang = Locale.preferredLanguages.first ?? "en_US"
        let formatted = preferredLang.replacingOccurrences(of: "-", with: "_")
        return formatted
    }

    // All available languages (code → name)
    func availableLanguages() -> [(code: String, name: String)] {
        languages
            .map { ($0.key, $0.value.lang) }
            .sorted { $0.name < $1.name } // Sort alphabetically by name
    }
}

// MARK: - Helper for dynamic JSON keys
struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    init?(stringValue: String) { self.stringValue = stringValue }
    var intValue: Int? { nil }
    init?(intValue: Int) { nil }
}
