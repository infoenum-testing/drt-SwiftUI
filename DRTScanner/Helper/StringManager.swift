//
//  StringManager.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 30/06/25.
//


import Foundation
import Combine
import IQAPIClient

final class StringManager: ObservableObject {
    static let shared = StringManager()

    @Published var strings: SelectedLangStrings
    @Published var allLangStrings: AppStringsModel?

    @Published var isShowAlert: Bool = false
    @Published var title: String = ""
    @Published var message: String = ""

    private let lastStringAPICallKey = "LastStringAPICallTimestamp"

    // MARK: - Init
    private init() {
        if !JsonFileManager.isAnyLanguageFileSaved(prefix: "AppStringData"),
           let bundleDict = JsonFileManager.loadJSONFromBundle(fileName: "language") {
            JsonFileManager.saveJSONToFile(json: bundleDict)
        }
        let selectedCode = Self.getOrSetInitialLanguageCode()

        guard let allStrings = JsonFileManager.loadJSONFromBundle(fileName: "language"),
              let jsonData = try? JSONSerialization.data(withJSONObject: allStrings, options: []),
              let appStrings = try? JSONDecoder().decode(AppStringsModel.self, from: jsonData) else {
            fatalError("❌ Failed to load and decode JSON from bundle.")
        }

        allLangStrings = appStrings
        guard let selectedStrings = appStrings[selectedCode] else {
            fatalError("❌ Selected language not found in JSON.")
        }
        strings = selectedStrings

        loadStringFromLocal()
    }

    // MARK: - Language Helpers (dynamic)
    static func allLanguages() -> [(code: String, name: String)] {
        // First try from saved file in Documents (if exists)
        if JsonFileManager.isAnyLanguageFileSaved(prefix: "AppStringData"),
           let dict = JsonFileManager.loadJSONFromFile() as? [String: Any] {
            return parseLanguages(from: dict)
        }
        
        // Fallback: load from bundled JSON file
        if let dict = JsonFileManager.loadJSONFromBundle(fileName: "language") as? [String: Any] {
            return parseLanguages(from: dict)
        }
        
        // Default: empty list
        return []
    }

    // Shared parser to avoid duplication
    private static func parseLanguages(from dict: [String: Any]) -> [(code: String, name: String)] {
        return dict.compactMap { key, value in
            if let langDict = value as? [String: Any],
               let langName = langDict["lang"] as? String {
                return (code: key, name: langName)
            }
            return nil
        }
        .sorted { $0.name < $1.name }
    }


    static func code(for nameOrCode: String) -> String {
        let langs = allLanguages()
        if let found = langs.first(where: { $0.code.caseInsensitiveCompare(nameOrCode) == .orderedSame ||
                                            $0.name.caseInsensitiveCompare(nameOrCode) == .orderedSame }) {
            return found.code
        }
        return nameOrCode
    }

    static func name(for codeOrName: String) -> String {
        let langs = allLanguages()
        if let found = langs.first(where: { $0.code.caseInsensitiveCompare(codeOrName) == .orderedSame ||
                                            $0.name.caseInsensitiveCompare(codeOrName) == .orderedSame }) {
            return found.name
        }
        return codeOrName
    }

    private static func getOrSetInitialLanguageCode() -> String {
        if let savedLang = UserDefaults.standard.string(forKey: "selectedLang") {
            return code(for: savedLang)
        } else {
            let systemCode = AppStringsModel.getSystemLangCode()
            let availableLangCodes = StringManager.allLanguages().map { $0.code }

            let normalized: String
            if availableLangCodes.contains(systemCode) {
                normalized = code(for: systemCode)
            } else {
                normalized = code(for: "en_US")
            }

            UserDefaults.standard.set(name(for: normalized), forKey: "selectedLang")
            return normalized
        }
    }

    // MARK: - Update Lang
    func updateLang(for nameOrCode: String) {
        let langCode = Self.code(for: nameOrCode)
        if let langStrings = allLangStrings?[langCode] {
            strings = langStrings
        }
    }

    func returnLangCode() -> String {
        Self.code(for: strings.lang)
    }

    func currentLang() -> String {
        Self.name(for: returnLangCode())
    }

    // MARK: - Loading Strings
    func loadStrings() {
        if !shouldMakeAPICall() {
            loadStringFromLocal()
            return
        }

        IQAPIClient.getStringLanguage { result in
            switch result {
            case .success(let stringsDict):
                DispatchQueue.main.async {
                    if let jsonData = try? JSONSerialization.data(withJSONObject: stringsDict, options: []),
                       let appStrings = try? JSONDecoder().decode(AppStringsModel.self, from: jsonData) {
                        self.allLangStrings = appStrings
                        if let savedLang = UserDefaults.standard.string(forKey: "selectedLang") {
                            self.updateLang(for: savedLang)
                        } else {
                            self.updateLang(for: Self.getOrSetInitialLanguageCode())
                        }
                        JsonFileManager.saveJSONToFile(json: stringsDict)
                        UserDefaults.standard.set(Date(), forKey: self.lastStringAPICallKey)
                    }
                }
            case .failure(let error):
                print("❌ Failed to fetch strings:", error)
            }
        }
    }

    func loadStringFromLocal() {
        if let localDict = JsonFileManager.loadJSONFromFile(),
           let jsonData = try? JSONSerialization.data(withJSONObject: localDict, options: []),
           let appStrings = try? JSONDecoder().decode(AppStringsModel.self, from: jsonData) {
            self.allLangStrings = appStrings
            if let savedLang = UserDefaults.standard.string(forKey: "selectedLang") {
                self.updateLang(for: savedLang)
            } else {
                self.updateLang(for: Self.getOrSetInitialLanguageCode())
            }
        }
    }

    private func shouldMakeAPICall() -> Bool {
        if let lastCall = UserDefaults.standard.object(forKey: lastStringAPICallKey) as? Date {
            return Date().timeIntervalSince(lastCall) / 3600 >= 24
        }
        return true
    }
}
