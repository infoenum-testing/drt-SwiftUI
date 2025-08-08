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
    private let lastStringAPICallKey = "LastStringAPICallTimestamp"
    
    static let shared = StringManager()
    @Published var strings: SelectedLangStrings?
    
    @Published var allLangStrings: AppStringsModel?
    
    @Published var isShowAlert: Bool = false
    @Published var title: String = ""
    @Published var message: String = ""
    
    private init() {
        loadDefaultStringsFromBundleIfNeeded()
        loadStringFromLocal()
    }
    
    func loadStrings() {
        if !shouldMakeAPICall() {
            loadStringFromLocal()
            return
        }
        
        IQAPIClient.getStringLanguage { result in
            switch result {
            case .success(let strings):
                print(strings)
                DispatchQueue.main.async {
                    if let jsonData = try? JSONSerialization.data(withJSONObject: strings, options: []) {
                        let decoder = JSONDecoder()
                        
                        do {
                            let appStrings = try decoder.decode(AppStringsModel.self, from: jsonData)
                            self.allLangStrings = appStrings
                            if let langCode = UserDefaults.standard.string(forKey: "selectedLang") {
                                self.updateLang(for: langCode)
                            } else {
                                self.updateLangBasedOnCode()
                            }
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
    
    func loadStringFromLocal() {
        if let strings = loadJSONFromFile(), let jsonData = try? JSONSerialization.data(withJSONObject: strings, options: []) {
            let decoder = JSONDecoder()
            
            do {
                let appStrings = try decoder.decode(AppStringsModel.self, from: jsonData)
                self.allLangStrings = appStrings
                if let langCode = UserDefaults.standard.string(forKey: "selectedLang") {
                    self.updateLang(for: langCode)
                } else {
                    self.updateLangBasedOnCode()
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
    }
    
    func loadJSONFromBundle(fileName: String, fileExtension: String = "json") -> [String: Any]? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("❌ File \(fileName).\(fileExtension) not found in bundle.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            return jsonObject as? [String: Any]
        } catch {
            print("❌ Error reading JSON from bundle: \(error)")
            return nil
        }
    }
    
    private func loadDefaultStringsFromBundleIfNeeded() {
        if !isAnyLanguageFileSaved(prefix: "AppStringData") {
            if let bundleDict = loadJSONFromBundle(fileName: "language") {
                saveJSONToFile(json: bundleDict) // Save to Documents for persistence
            }
        }
    }
    
    private func shouldMakeAPICall() -> Bool {
        let now = Date()
        if let lastCall = UserDefaults.standard.object(forKey: lastStringAPICallKey) as? Date {
               let hoursSinceLastCall = now.timeIntervalSince(lastCall) / 3600
               return hoursSinceLastCall >= 24
           }
           return true // No previous call, so allow
       }
    
    func updateLang(for code: String) {
        var tamp = "en_US"
        switch code {
        case allLangStrings?.enUS.lang ?? "ENGLISH":
            tamp = "en_US"
        case allLangStrings?.frCA.lang ?? "FRANÇAIS":
            tamp = "fr_CA"
        case allLangStrings?.esUS.lang ?? "ESPAÑOL":
            tamp = "es_US"
        default:
            tamp = "en_US"
        }
        self.strings =  allLangStrings?[tamp]
    }
    
    func updateLangBasedOnCode() {
        let code = LangCode.currentLangCode()
        if let selctedLang = allLangStrings?[code] {
            self.strings =  selctedLang
        } else {
            self.strings =  allLangStrings?["en_US"]
        }
    }
    
    func returnLangCode()-> String {
        let  code = strings?.lang ?? "en_US"
        switch code {
        case allLangStrings?.enUS.lang ?? "ENGLISH":
            return "en_US"
        case allLangStrings?.frCA.lang ?? "FRANÇAIS":
            return "fr_CA"
        case allLangStrings?.esUS.lang ?? "ESPAÑOL":
            return "es_US"
        default:
            return "en_US"
        }
    }
    
    func currentLang()-> String {
        let  code = strings?.lang ?? "en_US"
        switch code {
        case "en_US" :
            return allLangStrings?.enUS.lang ?? "ENGLISH"
        case "fr_CA" :
            return  allLangStrings?.frCA.lang ?? "FRANÇAIS"
        case "es_US" :
            return  allLangStrings?.esUS.lang ?? "ESPAÑOL"
        default:
            return allLangStrings?.enUS.lang ?? "ENGLISH"
        }
    }
}
