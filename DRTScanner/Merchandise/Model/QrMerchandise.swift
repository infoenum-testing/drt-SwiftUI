//
//  QrMerchandise.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/05/25.
//

import Foundation

struct QrMerchandise: Codable {
    
    let merch: [String]
    
    private enum CodingKeys: String, CodingKey {
        case merch = "merch"
    }
    
}
