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
    static func getLookUpByCreditCard(code: String , orderNumber: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<OrderModel, Error>) -> Void) -> DataRequest? {
        let path = APIPath.lookUpByCreditCard.rawValue
        let param: [String: Any] = ["c" : code, "q" : orderNumber, "devicename" : ""]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getOrderDetail(code: String , oId: Int, completionHandler: @Sendable @escaping (_ result: Swift.Result<OrderDetailModel, Error>) -> Void) -> DataRequest? {
        let path = APIPath.orderDetail.rawValue
        let param: [String: Any] = ["c" : code, "sid" : "289", "oid" : oId, "type" : "seats"]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
}
