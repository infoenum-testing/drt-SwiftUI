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
import AVFAudio

class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        IQAPIClient.configureAPIClient()
        configureAudioSession()
        return true
    }
    
    func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Audio session setup error: \(error.localizedDescription)")
        }
    }
}
