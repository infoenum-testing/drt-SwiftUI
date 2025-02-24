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
        let deviceName = UserDefaults.standard.string(forKey: StringConstants.Attributes.showId) ?? StringConstants.Common.unknownDevice
        
        guard let url = DRTHTTPServiceConstants.Show.url(forCode: sId, deviceName: deviceName) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = StringConstants.httpMethod.get
        
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
    
    private var isOfflineMode: Bool = false
    
    func offline() -> Bool {
        return isOfflineMode
    }
    
    func uploadOfflineData(showCode: String, showID: String, uploadProgressBlock: @escaping (CGFloat) -> Void, completionHandler: @escaping (Bool, String, Error?) -> Void) {
        DispatchQueue.global().async {
            for i in 1...100 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                    uploadProgressBlock(CGFloat(i) / 100.0)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                completionHandler(true, "Upload successful", nil)
            }
        }
    }
    
    func trashAllOfflineScans() {
        print("All offline scans deleted")
    }
    
    func goOffline(_ offline: Bool) {
        isOfflineMode = offline
    }
}
