//
//  JsonFileManager.swift
//  DRTScanner
//
//  Created by IE15 on 15/07/25.
//

import Foundation

struct JsonFileManager {
    
    static func saveJSONToFile(json: [String: Any], fileName: String = "AppStringData") {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentURL.appendingPathComponent(fileName)
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            try data.write(to: fileURL)
            print("✅ JSON saved to: \(fileURL)")
        } catch {
            print("❌ Failed to save JSON: \(error)")
        }
    }
    
    static func loadJSONFromFile(fileName: String = "AppStringData") -> [String: Any]? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentURL.appendingPathComponent(fileName)
        
        do {
            let data = try Data(contentsOf: fileURL)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return json
        } catch {
            print("❌ Failed to load JSON: \(error)")
            return nil
        }
    }
    
    static func isAnyLanguageFileSaved(prefix: String = "AppStringData") -> Bool {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: documentURL.path)
            return files.contains(where: { $0.hasPrefix(prefix) })
        } catch {
            print("❌ Failed to list files in directory: \(error)")
            return false
        }
    }
    
    static func loadJSONFromBundle(fileName: String, fileExtension: String = "json") -> [String: Any]? {
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
    
    /// New helper — Loads available languages (code, name) from local file or bundle
    static func readLanguagesFromSource() -> [(code: String, name: String)] {
        let sourceData = loadJSONFromFile() ?? loadJSONFromBundle(fileName: "language") ?? [:]
        guard let dict = sourceData as? [String: Any] else { return [] }
        
        return dict.compactMap { key, value in
            if let langObj = value as? [String: Any],
               let name = langObj["lang"] as? String {
                return (code: key, name: name)
            }
            return nil
        }.sorted { $0.name < $1.name }
    }
}
