//
//  StringManager.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 30/06/25.
//


import Foundation
import Combine
import IQAPIClient

class StringManager: ObservableObject {
    static let shared = StringManager()
    
    @Published var allLangStrings: AppStringsClass?
    @Published var strings: AppStrings?
    private init() {
        if let strings = loadJSONFromFile(),let jsonData = try? JSONSerialization.data(withJSONObject: strings, options: []) {
            let decoder = JSONDecoder()
            
            do {
                let appStrings = try decoder.decode(AppStringsClass.self, from: jsonData)
                self.allLangStrings = appStrings
                let langCode = UserDefaults.standard.string(forKey: "selectedLang") ?? LangCode.current()
                updateLang(for: langCode)
            } catch {
                print("Decoding error: \(error)")
            }
        }
    }
    
    func loadStrings() {
        IQAPIClient.getStringLanguage { result in
            switch result {
            case .success(let strings):
                print(strings)
                DispatchQueue.main.async {
                    if let jsonData = try? JSONSerialization.data(withJSONObject: strings, options: []) {
                        let decoder = JSONDecoder()
                        
                        do {
                            let appStrings = try decoder.decode(AppStringsClass.self, from: jsonData)
                            self.allLangStrings = appStrings
                            let langCode = UserDefaults.standard.string(forKey: "selectedLang") ?? LangCode.current()
                            self.updateLang(for: langCode)
                        } catch {
                            print("Decoding error: \(error)")
                        }
                    }
                    saveJSONToFile(json: strings)
                }
                
            case .failure(let error):
                print("Failed to fetch strings:", error)
            }
        }
    }
    
    func updateLang(for code: String) {
        var tamp = "en_US"
        switch code {
        case allLangStrings?.enUS.lang ?? "English":
            tamp = "en_US"
        case allLangStrings?.frCA.lang ?? "French":
            tamp = "fr_CA"
        case allLangStrings?.esUS.lang ?? "Spanish":
            tamp = "es_US"
        default:
            break
        }
        self.strings =  allLangStrings?[tamp]
    }
    
}
