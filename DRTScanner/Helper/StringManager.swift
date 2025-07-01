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

    @Published var strings: AppStrings?

    private init() {}

    func loadStrings() {
        IQAPIClient.getStringLanguage { result in
            switch result {
            case .success(let strings):
                DispatchQueue.main.async {
                    self.strings = strings
                }
            case .failure(let error):
                print("Failed to fetch strings:", error)
            }
        }
    }
}
