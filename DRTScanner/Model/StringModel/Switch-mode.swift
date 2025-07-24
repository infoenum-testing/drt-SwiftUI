//
//  Switch-mode.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 30, 2025
//
import Foundation

struct SwitchMode: Codable {
    
    let merch: String
    let tickets: String
    let question: String
    let seat: String
    let merchandise: String
    let yes: String
    let no: String
    
    private enum CodingKeys: String, CodingKey {
        case seat
        case merchandise
        case merch = "merch"
        case tickets = "tickets"
        case question = "question"
        case yes = "yes"
        case no = "no"
    }
    
}
