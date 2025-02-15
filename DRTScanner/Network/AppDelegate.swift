//
//  AppDelegate.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 06/02/25.
//

import Foundation
import UIKit
import IQAPIClient
import Alamofire
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        IQAPIClient.configureAPIClient()
        return true
    }
}
