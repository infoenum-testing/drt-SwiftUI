//
//  Home.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct HomeStrings: Codable {
    let serviceName: String
    let lookUpBy: String
    let orderNumber: String
    let name: String
    let phoneNumber: String
    let creditCard: String
    let seat: String
    let ok: String
    
    private enum CodingKeys: String, CodingKey {
        case serviceName = "service-name"
        case lookUpBy = "look-up-by"
        case orderNumber = "order-number"
        case name
        case phoneNumber = "phone-number"
        case creditCard = "credit-card"
        case seat
        case ok
    }
}
