 //
//  IQAPI+Base.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.
//


import SwiftUI
import Alamofire
import IQAPIClient
import Network

enum IQNSURLServerError : Int {
    case accessTokenExpired = 401
    case invalidRefreshToken = 101
}

public extension IQAPIClient {
    static func configureAPIClient() {
        //        IQAPIClient(baseURL: URL(string: APIPath.baseUrl.rawValue))
        IQAPIClient.default.baseURL = URL(string: APIPath.baseUrl.rawValue)
        IQAPIClient.default.httpHeaders["Content-Type"] = "application/json"
        IQAPIClient.default.httpHeaders["Accept"] = "application/json"
        IQAPIClient.default.debuggingEnabled = true
        
        IQAPIClient.default.responseModifierBlock = { (response, object) in
            
            guard let object = object as? [String: Any] else {
                /// We seding success here because we do not have single format of API's response
                return .success(object)
            }
            
            /// Handle Error cases
            if let statusCode = response.response?.statusCode {
                
                if let success = object["success"] as? Bool,
                   success,
                   let data = object["data"] as? [String : Any] {
                    if success {
                        return .success(data)
                    }
                } else if let success = object["success"] as? Bool,
                          success, let data = object["data"] as? [[String : Any]] {
                    if success {
                        return .success(data)
                    }
                } else if let success = object["success"] as? Bool,
                          success {
                    return .success(object)
                }
                
                if statusCode >= 400 && statusCode < 500 {
                    
                    if statusCode == NSURLClientError.unauthorized401.rawValue {
                        
                        //Handle 401 in basic API calls...
                        if let message = object["message"] as? String {
                            let error = NSError(domain: StringConstants.APIError.serverError, code: statusCode, userInfo: [NSLocalizedDescriptionKey: message])
                            return .error(error)
                        }
                        
                        // Handle refresh case
                        let error = NSError(domain: StringConstants.APIError.serverError, code: IQNSURLServerError.accessTokenExpired.rawValue, userInfo: [NSLocalizedDescriptionKey: "Access Token expired"])
                        return .error(error)
                    }
                    
                    let errorMessage = object["message"] as? String ?? StringConstants.APIError.clientError
                    
                    let error = NSError(domain: StringConstants.APIError.clientError, code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    return .error(error)
                    
                } else if statusCode >= 500 && statusCode < 600 {
                    let errorMessage = object["message"] as? String ?? StringConstants.APIError.clientError
                    let error = NSError(domain: StringConstants.APIError.serverError, code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    return .error(error)
                }
                
            } else if let message = object["message"] as? String {
                let error = NSError(domain: StringConstants.APIError.serverError, code: NSURLErrorBadServerResponse, userInfo: [NSLocalizedDescriptionKey: message])
                return .error(error)
            }
            return .success(object)
        }
    }
}


extension IQAPIClient {
    
    /// `Success, Failure` either be a `valid JSON type` or must conform to `Decodable` protocol
    static func refreshableSendRequest<Success>(path: String,
                                                method: HTTPMethod = .get,
                                                parameters: Parameters? = nil,
                                                encoding: ParameterEncoding? = nil,
                                                headers: HTTPHeaders? = nil,
                                                options: Options = [], canRefreshToken: Bool = true) async throws -> (httpResponse: HTTPURLResponse, result: Success) {
        IQAPIClient.setUserAuthToken()
        
        do {
            let result: (httpResponse: HTTPURLResponse, result: Success)
            result = try await IQAPIClient.default.sendRequest(path: path, method: method, parameters: parameters, encoding: encoding, headers: headers, options: options)
            print("\(result.httpResponse.headers)")
            return result
        } catch {
            let errorCode: Int = (error as NSError).code
            if errorCode == IQNSURLServerError.accessTokenExpired.rawValue, canRefreshToken {
                do {
                    let newToken = try await IQAPIClient.refreshToken()
                    if let token = newToken.token {
                       // KeychainManager.saveToken(token)
                    }
                    return try await self.refreshableSendRequest(path: path, method: method, parameters: parameters, encoding: encoding, headers: headers, options: options, canRefreshToken: false)
                } catch {
                    throw error
                }
            } else if errorCode == IQNSURLServerError.invalidRefreshToken.rawValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    /// Session Expired
                    ///
                   // KeychainManager.removeToken()
                   // NotificationCenter.default.post(name: .sessionExpired, object: nil)
                }
                throw error
            } else {
                throw error
            }
        }
    }
}

// MARK: - Refresh Token -

extension IQAPIClient {
    
    static func refreshToken() async throws -> RefreshTokenResponse {
        
        let path = APIPath.refreshtoken.rawValue
        var token = KeychainManager.getToken() ?? ""
        //Workaround
        token = token.replacingOccurrences(of: "bearer ", with: "")
        let refreshToken = KeychainManager.getRefreshToken()
        let params: Parameters = ["refreshToken": refreshToken,
                                  "token": token]
        
        
        return try await IQAPIClient.default.sendRequest(path: path, method: .post,parameters: params, options: [.successSound, .failedSound]).result
    }
}


// MARK: - Authentication -

public extension IQAPIClient {
    
    static func setUserAuthToken() {
        if var token = KeychainManager.getToken() {
            //Workaround
            token = token.replacingOccurrences(of: "bearer ", with: "")
            IQAPIClient.default.httpHeaders["Authorization"] = "bearer \(token)"
        }
    }
}
