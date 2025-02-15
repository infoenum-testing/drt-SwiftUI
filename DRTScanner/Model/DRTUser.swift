////
////  DRTScanningSelectionType.swift
////  DRTScanner
////
////  Created by IE Mac 05 on 05/02/25.
////
//
//
//import Foundation
//
//enum DRTScanningSelectionType: String, Codable {
//    case merchandise = "merchandise"
//    case seat = "seat"
//}
//
//final class DRTUser: Codable {
//    static private let userDefaultsKey = "show_id"
//
//    var showCode: String?
//    var valid: Bool = false
//    var showID: String?
//    var studioID: String?
//    var showDate: String?
//    var stats: String?
//    var skin: String?
//    var poster: String?
//    var scanningType: DRTScanningSelectionType = .seat
//
//    static var currentUser: DRTUser? {
//        get {
//            guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return nil }
//            return try? JSONDecoder().decode(DRTUser.self, from: data)
//        }
//        set {
//            if let newValue = newValue, let encodedData = try? JSONEncoder().encode(newValue) {
//                UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
//            } else {
//                UserDefaults.standard.removeObject(forKey: userDefaultsKey)
//            }
//        }
//    }
//    
//    static var isUserLoggedIn: Bool {
//        return currentUser?.showCode != nil
//    }
//    
//    func setUserInfo(from dictionary: [String: Any]) {
//        valid = dictionary["valid"] as? Bool ?? false
//        showID = dictionary["show_id"] as? String
//        studioID = dictionary["studio_id"] as? String
//        showDate = dictionary["show_dt"] as? String
//        stats = dictionary["stats"] as? String
//        skin = dictionary["skin"] as? String
//        poster = dictionary["poster"] as? String
//    }
//    
//    static func logout() {
//        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
//    }
//}
