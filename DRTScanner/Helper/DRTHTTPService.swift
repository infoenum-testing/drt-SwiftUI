//
//  DRTHTTPService.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 04/02/25.
//

import Foundation

class DRTHTTPService {
    
    static let shared = DRTHTTPService()

    func showCode(sId: String) async throws -> [String: Any] {
        let deviceName = UserDefaults.standard.string(forKey: "show_id") ?? "UnknownDevice"
        
        guard let url = DRTHTTPServiceConstants.Show.url(forCode: sId, deviceName: deviceName) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("Response data: \(jsonString)")
        }
        
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return jsonObject
            } else {
                throw URLError(.cannotParseResponse)
            }
        } catch {
            throw URLError(.cannotParseResponse)
        }
    }
}
