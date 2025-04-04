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
        let deviceName = DeviceManager.shared.getDeviceName()
        let param: [String: Any] = ["c" : code, "devicename" : deviceName]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
   
    @discardableResult
    static func getLookUpByOrder(code: String , orderNumber: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[OrdersNewApi], Error>) -> Void) -> DataRequest? {
        let path = APIPath.lookUpByOrder.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let param: [String: Any] = ["c" : code, "q" : orderNumber, "devicename" : deviceName]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getLookUpByCreditCard(code: String , ccNumber: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[OrdersNewApi], Error>) -> Void) -> DataRequest? {
        let path = APIPath.lookUpByCreditCard.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let param: [String: Any] = ["c" : code, "q" : ccNumber, "devicename" : deviceName]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getLookUpByPhone(code: String , phoneNumber: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[OrdersNewApi], Error>) -> Void) -> DataRequest? {
        let path = APIPath.lookUpByPhone.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let param: [String: Any] = ["c" : code, "q" : phoneNumber, "devicename" : deviceName]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getLookUpByName(code: String , orderName: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[OrdersNewApi], Error>) -> Void) -> DataRequest? {
        let path = APIPath.lookUpByname.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let param: [String: Any] = ["c" : code, "q" : orderName, "devicename" : deviceName]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getOrderDetail(code: String, sid: String, oId: Int, type: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<OrdersNewApi, Error>) -> Void) -> DataRequest? {
        let path = APIPath.orderDetail.rawValue
        let param: [String: Any] = ["c" : code, "sid" : sid, "oid" : oId, "type" : type]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getSection(code: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[[String: Any]], Error>) -> Void) -> DataRequest? {
        let path = APIPath.section.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let param: [String: Any] = ["c" : code, "ds" : "sections", "devicename" : deviceName]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getRow(code: String, section: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[[String: Any]], Error>) -> Void) -> DataRequest? {
        let path = APIPath.section.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let param: [String: Any] = ["c" : code, "ds" : "rows", "s" : section, "devicename" : deviceName]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getSeats(code: String, section: String, row: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[[String: Any]], Error>) -> Void) -> DataRequest? {
        let path = APIPath.section.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let param: [String: Any] = ["c" : code, "ds" : "seats", "s" : section, "r" : row, "devicename" : deviceName]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func getSeatsResults(code: String, section: String, row: String, seat: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<OrderDetailModel, Error>) -> Void) -> DataRequest? {
        let path = APIPath.seat.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let param: [String: Any] = ["c" : code, "section": section, "row" : row, "seat" : seat, "devicename" : deviceName]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func scanTicket(code: String, qr: [String], completionHandler: @Sendable @escaping (_ result: Swift.Result<[String: Any], Error>) -> Void) -> DataRequest? {
        let deviceName = DeviceManager.shared.getDeviceName()
        let path = "https://api.drttix.com/scanner-v3/ticket?c=\(code)&devicename=\(deviceName)"
        let param: [String: Any] = ["qr" : qr]
        
        return IQAPIClient.default.sendRequest(url: path, method: .post, parameters: param, encoding: JSONEncoding.default, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func scanTicketQrCode(code: String, type: String, qr: [String], completionHandler: @Sendable @escaping (_ result: Swift.Result<[String: Any], Error>) -> Void) -> DataRequest? {
        let deviceName = DeviceManager.shared.getDeviceName()
        let path = "https://api.drttix.com/scanner-v3/ticket?c=\(code)&devicename=\(deviceName)"
        
        let param: [String: Any] = [type: qr]
        
        return IQAPIClient.default.sendRequest(url: path, method: .post, parameters: param, encoding: JSONEncoding.default, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func scanProductQrCode(code: String, qr: [String], completionHandler: @Sendable @escaping (_ result: Swift.Result<[String: Any], Error>) -> Void) -> DataRequest? {
        let deviceName = DeviceManager.shared.getDeviceName()
        let path = "https://api.drttix.com/scanner/merch/?c=\(code)&devicename=\(deviceName)"
        
        let param: [String: Any] = ["merch": qr]
        
        return IQAPIClient.default.sendRequest(url: path, method: .post, parameters: param, encoding: JSONEncoding.default, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func scanTicketBarcode(code: String, barcode: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<Any, Error>) -> Void) -> DataRequest? {
        let path = APIPath.ticket.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let param: [String: Any] = ["c" : code, "bc": barcode, "devicename" : deviceName]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }

    
    @discardableResult
    static func getAllDataOffline(code: String, username: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<Any, Error>) -> Void) -> DataRequest? {
        let path = APIPath.selectAllDataOffine.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let param: [String: Any] = ["c" : code, "username": username, "devicename" : deviceName]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    @discardableResult
    static func uploadAllOfflineData(code: String, data: [String: Any], completionHandler: @Sendable @escaping (_ result: Swift.Result<Any, Error>) -> Void) -> DataRequest? {
        let deviceName = DeviceManager.shared.getDeviceName()
        let path = "https://api.drttix.com/scanner-v3/db/ul?c=\(code)&devicename=\(deviceName)"
        
        guard let dbCode = data["db_code"] as? String,
              let requestData = data["data"] as? [String: Any] else {
            completionHandler(.failure(NSError(domain: "Invalid Data", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid db_code/data"])))
            return nil
        }
        
        let param: [String: Any] = ["db_code": dbCode, "data": requestData]

        return IQAPIClient.default.sendRequest(url: path, method: .post, parameters: param, encoding: JSONEncoding.default, completionHandler: completionHandler)
    }
}
