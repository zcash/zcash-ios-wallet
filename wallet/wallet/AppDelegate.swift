//
//  AppDelegate.swift
//  wallet
//
//  Created by Francisco Gindre on 12/26/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import UIKit
import BackgroundTasks


#if ENABLE_LOGGING
import Bugsnag
import zealous_logger
let tracker = MixPanelLogger(token: Constants.mixpanelProject)
let logger = SimpleFileLogger(logsDirectory: try! URL.logsDirectory(), alsoPrint: true, level: .debug)
#else
let tracker = NullLogger()
let logger = SimpleLogger(logLevel: .debug)
#endif

class AppDelegate: UIResponder, UIApplicationDelegate {  
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        #if targetEnvironment(simulator)
        if ProcessInfo.processInfo.environment["isTest"] != nil {
            return true
        }
        #endif
        
        #if ENABLE_LOGGING
        Bugsnag.start(withApiKey: Constants.bugsnagApiKey)
        #endif
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
    
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
  
}
