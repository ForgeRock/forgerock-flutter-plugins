//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation
import FRAuthenticator

class FRAppDelegate: NSObject, UIApplicationDelegate, FlutterStreamHandler {
    
    static let shared = FRAppDelegate()
    
    var channel: FlutterMethodChannel?
    var initialLink : String?
    var latestLink : String?
    var hasAlreadyLaunched : Bool?
    
    private var eventSink: FlutterEventSink?
    
    
    //MARK: - AppDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NSLog("application:didFinishLaunchingWithOptions: \(String(describing: launchOptions))")
        
        setupNotifications()
        
        if let notificationInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any] {
            NSLog("UIApplication.LaunchOptionsKey.remoteNotification: \(notificationInfo)")
            FRAClientWrapper.shared.handleMessageWithPayload(userInfo: notificationInfo)
        }
        
        if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL {
            self.initialLink = url.absoluteString
            self.latestLink = self.initialLink
            
            NSLog("App launched with DeepLink - initialLink: \(String(describing: self.initialLink))")
        }
        
        self.hasAlreadyLaunched = UserDefaults.standard.bool(forKey: "hasAlreadyLaunched")
        if (!self.hasAlreadyLaunched!) {
            UserDefaults.standard.set(true, forKey: "hasAlreadyLaunched")
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NSLog("application:open:options:")
        self.latestLink = url.absoluteString
        
        guard let eventSink = self.eventSink else {
            return false
        }
        
        NSLog("App opened with DeepLink - latestLink: \(self.latestLink!)");
        
        eventSink(self.latestLink!)
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        NSLog("application:continue:restorationHandler:")
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let url = userActivity.webpageURL!
            NSLog(url.absoluteString)
            self.latestLink = url.absoluteString
            if(self.eventSink != nil) {
                self.initialLink = self.latestLink
            }
            return true
        }
        return false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NSLog("applicationWillEnterForeground:")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        NSLog("applicationDidEnterBackground:")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NSLog("applicationDidBecomeActive:")
        self.processPendingDeliveredNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NSLog("application:didRegisterForRemoteNotificationsWithDeviceToken:deviceToken: \(deviceToken.hexString)")
        FRAClientWrapper.shared.registerDeviceToken(deviceToken: deviceToken)
        channel?.invokeMethod("onToken", arguments: deviceToken.hexString)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) -> Void {
        NSLog("application:didReceiveRemoteNotification:userInfo: \(userInfo)")
        FRAClientWrapper.shared.handleMessageWithPayload(userInfo: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        NSLog("application:didReceiveRemoteNotification:fetchCompletionHandler:userInfo: \(userInfo)")
        
        let pushNotification : PushNotification? = FRAClientWrapper.shared.handleMessageWithPayload(userInfo: userInfo)
        let state = UIApplication.shared.applicationState
        if state == .active {
            NSLog("Update listeners about pending notification")
            channel?.invokeMethod("onMessage", arguments: pushNotification?.toJson())
        }
        
        completionHandler(.newData)
    }
    
    
    //MARK: - FlutterStreamHandler
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
}


//MARK: - Extensions

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}

