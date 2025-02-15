//
//  RefreshTokenResponse.swift
//  ALittleSpot
//
//  Created by IE Mac 07 on 09/06/24.
//

import Foundation


struct RefreshTokenResponse: Codable {
    var token: String?
    var isSucceed: Bool?
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case token = "token"
        case isSucceed = "isSucceed"
        case message = "message"
    }
}
