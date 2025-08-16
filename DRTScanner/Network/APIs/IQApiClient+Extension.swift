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
    
    /// Fetches localized string data (e.g., translations or labels).
    @discardableResult
    static func getStringLanguage(completionHandler: @Sendable @escaping (_ result: Swift.Result<[String: Any], Error>) -> Void) -> DataRequest? {
        let path = APIPath.stringLang.rawValue
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["lang" : lanCode]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    /// Retrieves show-related data using a specific code.
    @discardableResult
    static func getShowCodeData(code: String , completionHandler: @Sendable @escaping (_ result: Swift.Result<DRTUser, Error>) -> Void) -> DataRequest? {
        let path = APIPath.showCode.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["c" : code, "devicename" : deviceName,"lang": lanCode]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
   
    /// Looks up orders by order number.
    @discardableResult
    static func getLookUpByOrder(code: String , orderNumber: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[OrdersNewApi], Error>) -> Void) -> DataRequest? {
        let path = APIPath.lookUpByOrder.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["c" : code, "q" : orderNumber, "devicename" : deviceName,"lang": lanCode]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    /// Looks up orders by credit card number.
    @discardableResult
    static func getLookUpByCreditCard(code: String , ccNumber: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[OrdersNewApi], Error>) -> Void) -> DataRequest? {
        let path = APIPath.lookUpByCreditCard.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["c" : code, "q" : ccNumber, "devicename" : deviceName, "lang" : lanCode]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    /// Looks up orders by phone number.
    @discardableResult
    static func getLookUpByPhone(code: String , phoneNumber: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[OrdersNewApi], Error>) -> Void) -> DataRequest? {
        let path = APIPath.lookUpByPhone.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["c" : code, "q" : phoneNumber, "devicename" : deviceName, "lang" : lanCode]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    /// Looks up orders by customer name.
    @discardableResult
    static func getLookUpByName(code: String , orderName: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[OrdersNewApi], Error>) -> Void) -> DataRequest? {
        let path = APIPath.lookUpByname.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["c" : code, "q" : orderName, "devicename" : deviceName, "lang" : lanCode]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    /// Retrieves detailed order information using order ID and session ID.
    @discardableResult
    static func getOrderDetail(code: String, sid: String, oId: Int, type: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<OrdersNewApi, Error>) -> Void) -> DataRequest? {
        let path = APIPath.orderDetail.rawValue
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["c" : code, "sid" : sid, "oid" : oId, "type" : type, "lang" : lanCode]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    /// Fetches all sections available for a given show code.
    @discardableResult
    static func getSection(code: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[[String: Any]], Error>) -> Void) -> DataRequest? {
        let path = APIPath.section.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["c" : code, "ds" : "sections", "devicename" : deviceName, "lang" : lanCode]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    /// Fetches all rows in a given section.
    @discardableResult
    static func getRow(code: String, section: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[[String: Any]], Error>) -> Void) -> DataRequest? {
        let path = APIPath.section.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["c" : code, "ds" : "rows", "s" : section, "devicename" : deviceName, "lang" : lanCode]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    /// Fetches all seats in a given row of a section.
    @discardableResult
    static func getSeats(code: String, section: String, row: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<[[String: Any]], Error>) -> Void) -> DataRequest? {
        let path = APIPath.section.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["c" : code, "ds" : "seats", "s" : section, "r" : row, "devicename" : deviceName, "lang" : lanCode]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    /// Fetches results for a specific seat (e.g. ticket info).
    @discardableResult
    static func getSeatsResults(code: String, section: String, row: String, seat: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<OrderDetailModel, Error>) -> Void) -> DataRequest? {
        let path = APIPath.seat.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["c" : code, "section": section, "row" : row, "seat" : seat, "devicename" : deviceName, "lang" : lanCode]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    /// Scans a ticket QR codes.
    @discardableResult
    static func scanTicket(code: String, qr: [String], completionHandler: @Sendable @escaping (_ result: Swift.Result<ScanResponse, Error>) -> Void) -> DataRequest? {
        let deviceName = DeviceManager.shared.getDeviceName()
        let path = "https://api.drttix.com/scanner-v3/ticket?c=\(code)&devicename=\(deviceName)"
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["seat" : qr, "lang" : lanCode]
        
        return IQAPIClient.default.sendRequest(url: path, method: .post, parameters: param, encoding: JSONEncoding.default, completionHandler: completionHandler)
    }
    
    /// Scans ticket QR codes with a specified type (e.g., "merch", "seat").
    @discardableResult
    static func scanTicketQrCode(code: String, type: String, qr: [String], completionHandler: @Sendable @escaping (_ result: Swift.Result<[String: Any], Error>) -> Void) -> DataRequest? {
        let deviceName = DeviceManager.shared.getDeviceName()
        let path = "https://api.drttix.com/scanner-v3/ticket?c=\(code)&devicename=\(deviceName)"
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = [type: qr, "lang" : lanCode]
        
        return IQAPIClient.default.sendRequest(url: path, method: .post, parameters: param, encoding: JSONEncoding.default, completionHandler: completionHandler)
    }
    
    /// Scans merchandise QR codes.
    @discardableResult
    static func scanProductQrCode(code: String, qr: [String], completionHandler: @Sendable @escaping (_ result: Swift.Result<[String: Any], Error>) -> Void) -> DataRequest? {
        let deviceName = DeviceManager.shared.getDeviceName()
        let path = "https://api.drttix.com/scanner-v3/merch/?c=\(code)&devicename=\(deviceName)"
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["merch": qr, "lang" : lanCode]
        return IQAPIClient.default.sendRequest(url: path, method: .post, parameters: param, encoding: JSONEncoding.default, completionHandler: completionHandler)
    }
    
    /// Scans a ticket using a barcode
    @discardableResult
    static func scanTicketBarcode(code: String, barcode: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<Any, Error>) -> Void) -> DataRequest? {
        let path = APIPath.ticket.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["c" : code, "bc": barcode, "devicename" : deviceName, "lang" : lanCode]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }

    /// Downloads all offline data from the server for a user/device.
    @discardableResult
    static func getAllDataOffline(code: String, username: String, completionHandler: @Sendable @escaping (_ result: Swift.Result<Any, Error>) -> Void) -> DataRequest? {
        let path = APIPath.selectAllDataOffine.rawValue
        let deviceName = DeviceManager.shared.getDeviceName()
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["c" : code, "username": username, "devicename" : deviceName, "lang" : lanCode]
        return IQAPIClient.default.sendRequest(path: path, method: .get, parameters: param, completionHandler: completionHandler)
    }
    
    /// Uploads offline scan data back to the server.
    @discardableResult
    static func uploadAllOfflineData(code: String, data: [String: Any], completionHandler: @Sendable @escaping (_ result: Swift.Result<Any, Error>) -> Void) -> DataRequest? {
        let deviceName = DeviceManager.shared.getDeviceName()
        let path = "https://api.drttix.com/scanner-v3/db/ul?c=\(code)&devicename=\(deviceName)"
        
        guard let dbCode = data["dbCode"] as? String,
              let requestData = data["data"] as? [String: Any] else {
            completionHandler(.failure(NSError(domain: "Invalid Data", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid db_code/data"])))
            return nil
        }
        let lanCode = StringManager.shared.returnLangCode()
        let param: [String: Any] = ["dbCode": dbCode, "data": requestData, "lang" : lanCode]
        return IQAPIClient.default.sendRequest(url: path, method: .post, parameters: param, encoding: JSONEncoding.default, completionHandler: completionHandler)
    }
}
