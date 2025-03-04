//
//  OfflineDataModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 24/02/25.
//

import Foundation

struct OfflineDataModel: Codable {
    
    let valid: Bool?
    let message: String?
    let showId: Int?
    let studioId: Int?
    let showDt: String?
    let dbCode: String?
    let orders: [OrdersOfflineModel]?
  //  let sold: [Sold]?
   // let unsold: [Unsold]?
    
    private enum CodingKeys: String, CodingKey {
        case valid = "valid"
        case message = "message"
        case showId = "show_id"
        case studioId = "studio_id"
        case showDt = "show_dt"
        case dbCode = "db_code"
        case orders = "orders"
      //  case sold = "sold"
       // case unsold = "unsold"
    }
}

import Foundation

struct OrdersOfflineModel: Codable {

    let oid: Int?
    let buyerName: String?
    let cc: String?
    let phone: String?

    private enum CodingKeys: String, CodingKey {
        case oid = "0"
        case buyerName = "1"
        case cc = "2"
        case phone = "3"
    }

}

//import Foundation
//
//struct Sold: Codable {
//
//    let 0: Int?
//    let 1: String?
//    let 2: String?
//    let 3: String?
//    let 4: String?
//    let 5: [String]?
//    let 6: Any?
//    let 7: Bool?
//
//    private enum CodingKeys: String, CodingKey {
//        case 0 = "0"
//        case 1 = "1"
//        case 2 = "2"
//        case 3 = "3"
//        case 4 = "4"
//        case 5 = "5"
//        case 6 = "6"
//        case 7 = "7"
//    }
//
//}
//
//import Foundation
//
//struct Unsold: Codable {
//
//    let 0: Int?
//    let 1: String?
//    let 2: String?
//    let 3: String?
//    let 4: String?
//    let 5: [String]?
//    let 6: Int?
//    let 7: Bool?
//    let 8: String?
//
//    private enum CodingKeys: String, CodingKey {
//        case 0 = "0"
//        case 1 = "1"
//        case 2 = "2"
//        case 3 = "3"
//        case 4 = "4"
//        case 5 = "5"
//        case 6 = "6"
//        case 7 = "7"
//        case 8 = "8"
//    }
//
//}
