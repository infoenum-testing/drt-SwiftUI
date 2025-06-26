//
//  APIError.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 26/06/25.
//


enum APIError: Error {
    case serverError(message: String)
    case networkError
    case decodingError
}
