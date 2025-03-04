//
//  IQApiClient+Extension.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 06/02/25.
//

import Foundation
import IQAPIClient
import Alamofire

extension IQAPIClient {
    
    @discardableResult
    static func getStringLanguage(completionHandler: @Sendable @escaping (_ result: Swift.Result<DRTUser, Error>) -> Void) -> DataRequest? {
        let path = APIPath.stringLang.rawValue
        let param: [String: Any] = ["lang" : "en-US"]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getShowCodeData(code: String , completionHandler: @Sendable @escaping (_ result: Swift.Result<DRTUser, Error>) -> Void) -> DataRequest? {
        let path = APIPath.showCode.rawValue
        let param: [String: Any] = ["c" : code, "devicename" : ""]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
   
    @discardableResult
    static func getLookUpByOrder(code: String , orderNumber: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<OrderModel, Error>) -> Void) -> DataRequest? {
        let path = APIPath.lookUpByOrder.rawValue
        let param: [String: Any] = ["c" : code, "q" : orderNumber, "devicename" : ""]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getLookUpByCreditCard(code: String , ccNumber: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<OrderModel, Error>) -> Void) -> DataRequest? {
        let path = APIPath.lookUpByCreditCard.rawValue
        let param: [String: Any] = ["c" : code, "q" : ccNumber, "devicename" : ""]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getLookUpByPhone(code: String , phoneNumber: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<OrderModel, Error>) -> Void) -> DataRequest? {
        let path = APIPath.lookUpByPhone.rawValue
        let param: [String: Any] = ["c" : code, "q" : phoneNumber, "devicename" : ""]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getLookUpByName(code: String , orderName: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<OrderModel, Error>) -> Void) -> DataRequest? {
        let path = APIPath.lookUpByname.rawValue
        let param: [String: Any] = ["c" : code, "q" : orderName, "devicename" : ""]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getOrderDetail(code: String , oId: Int, completionHandler: @Sendable @escaping (_ result: Swift.Result<OrderDetailModel, Error>) -> Void) -> DataRequest? {
        let path = APIPath.orderDetail.rawValue
        let param: [String: Any] = ["c" : code, "sid" : "289", "oid" : oId, "type" : "seats"]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getSection(code: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[String], Error>) -> Void) -> DataRequest? {
        let path = APIPath.section.rawValue
        let param: [String: Any] = ["c" : code, "ds" : "sections", "devicename" : ""]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getRow(code: String, section: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[String], Error>) -> Void) -> DataRequest? {
        let path = APIPath.section.rawValue
        let param: [String: Any] = ["c" : code, "ds" : "rows", "s" : section, "devicename" : ""]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getSeats(code: String, section: String, row: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[String], Error>) -> Void) -> DataRequest? {
        let path = APIPath.section.rawValue
        let param: [String: Any] = ["c" : code, "ds" : "seats", "s" : section, "r" : row, "devicename" : ""]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getSeatsResults(code: String, section: String, row: String, seat: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<OrderDetailModel, Error>) -> Void) -> DataRequest? {
        let path = APIPath.seat.rawValue
        let param: [String: Any] = ["c" : code, "section": section, "row" : row, "seat" : seat, "devicename" : ""]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getTicket(code: String , completionHandler: @Sendable @escaping (_ result: Swift.Result<String, Error>) -> Void) -> DataRequest? {
        let path = APIPath.ticket.rawValue
        let param: [String: Any] = ["c" : code, "devicename" : ""]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getAllDataOffline(code: String, username: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<Any, Error>) -> Void) -> DataRequest? {
        let path = APIPath.selectAllDataOffine.rawValue
        let param: [String: Any] = ["c" : code, "username": username, "devicename" : "iPhone-16-Plus-kxs9Jii6"]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func uploadAllOfflineData(code: String, sId: String, dbCode: String, username: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<Any, Error>) -> Void) -> DataRequest? {
        let path = APIPath.uploadAllDataOffine.rawValue
        let param: [String: Any] = ["c" : code, "sid": sId, "db_code": "8E98E90F-9925-4EA2-B994-68D3259D93C0", "username": username, "devicename" : "iPhone-16-Plus-kxs9Jii6"]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
}
