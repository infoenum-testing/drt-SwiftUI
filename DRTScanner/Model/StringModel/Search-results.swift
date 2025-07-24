//
//  Search-results.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct SearchResults: Codable {
    
    let cc: String
    let counts: String
    let order: String
    let phoneNumber: String
    let resultNotFound: String
    let totalResults: String
    let search: String
    let loading: String
    let nomerchandiseFound: String
    
    private enum CodingKeys: String, CodingKey {
        case cc
        case counts
        case order
        case phoneNumber = "phone-number"
        case resultNotFound = "result-not-found"
        case totalResults = "total-results"
        case nomerchandiseFound = "nomerchandiseFound"
        case search = "search"
        case loading = "loading"
    }
    
}
