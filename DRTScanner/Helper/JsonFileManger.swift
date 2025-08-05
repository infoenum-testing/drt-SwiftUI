//
//  JsonFileManger.swift
//  DRTScanner
//
//  Created by IE15 on 15/07/25.
//

import Foundation

func saveJSONToFile(json: [String: Any], fileName: String = "AppStringData") {
    let fileManager = FileManager.default
    guard let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    let fileURL = documentURL.appendingPathComponent(fileName)
    
    do {
        let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        try data.write(to: fileURL)
        UserDefaults.standard.set(Date(), forKey: "LastStringAPICallTimestamp")
        print("✅ JSON saved to: \(fileURL)")
    } catch {
        print("❌ Failed to save JSON: \(error)")
    }
}

func loadJSONFromFile(fileName: String = "AppStringData") -> [String: Any]? {
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
