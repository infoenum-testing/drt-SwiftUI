//
//  IQAPIClient+APIPath.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.
//

import Foundation

public enum APIPath: String {
    
    // MARK: - BaseUrl -
    
//    case baseUrl = "https://api.drttix.com/scanner"
    case baseUrl = "https://api.drttix.com/scanner-v3"
    
    // MARK: - Login -
    
    case refreshtoken = "refreshtoken"
    case showCode = "/show"
    case lookUpByOrder = "/orders/by-number"
    case orderDetail = "/order"
    case lookUpByCreditCard = "orders/by-cc"
    case lookUpByPhone = "orders/by-phone"
    case lookUpByname = "orders/by-name"
    case section = "/db/q"
    case seat = "/seat"
    case stringLang = "/strings"
    case ticket = "/ticket"
    
    // Offline APi
    case selectAllDataOffine = "/db/dl"
    case uploadAllDataOffine = "/db/ul"
}
