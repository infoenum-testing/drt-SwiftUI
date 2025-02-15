//
//  IQAPIClient+APIPath.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.
//

import Foundation

public enum APIPath: String {
    
    // MARK: - BaseUrl -
    
    case baseUrl = "https://api.drttix.com/scanner"
    
    // MARK: - Login -
    
    case refreshtoken = "refreshtoken"
    case showCode = "/show"
    case lookUpByOrder = "/orders/by-number"
    case orderDetail = "/order"
    case lookUpByCreditCard = "orders/by-cc"
}
