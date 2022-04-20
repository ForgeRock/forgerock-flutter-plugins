//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import UIKit
import Flutter
import WatchConnectivity
import forgerock_authenticator

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
      
    var session: WCSession?
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Delegate Notification center
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        
        // Activate session with Apple Watch
        if WCSession.isSupported() {
            self.session = WCSession.default;
            self.session?.delegate = self;
            self.session?.activate();
            debugLog("WCSession started")
        } else {
            debugLog("The current device does not support WCSession")
        }

        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugLog(error)
    }
    
}

extension AppDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugLog("activationDidCompleteWith: \(activationState)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        debugLog("sessionDidBecomeInactive: \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        debugLog("sessionDidDeactivate: \(session)")
        
        self.session?.activate()
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        debugLog("message received: \(applicationContext)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        debugLog("message received: \(message)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        debugLog("message received with replyHandler: \(message)")

        DispatchQueue.main.async {
            if let method = message["method"] as? String, let data = message["data"] as? [String: Any] {
                if(method == "sendNotificationToPhone") {
                    let approve = data["approve"] as! Bool
                    let userInfo = data["userInfo"] as! [AnyHashable : Any] 
                    FRAClientWrapper.shared.handleMessageFromWatch(userInfo: userInfo, approve: approve, replyHandler: replyHandler)
                }
            }
        }

    }

}

