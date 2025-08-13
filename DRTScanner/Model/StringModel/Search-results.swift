//
//  Search-results.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct SearchResults: Codable {
    let counts: String
    let totalResults: String
    let order: String
    let cc: String
    let phoneNumber: String
    let resultNotFound: String
    let loading: String
    let nomerchandiseFound: String
    let search: String
    
    private enum CodingKeys: String, CodingKey {
        case counts
        case totalResults = "total-results"
        case order
        case cc
        case phoneNumber = "phone-number"
        case resultNotFound = "result-not-found"
        case loading
        case nomerchandiseFound
        case search
    }
}
