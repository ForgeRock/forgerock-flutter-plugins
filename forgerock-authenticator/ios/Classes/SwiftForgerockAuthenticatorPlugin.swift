//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Flutter
import UIKit
import FRAuthenticator
import UserNotifications

public class SwiftForgerockAuthenticatorPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
  
    let channel: FlutterMethodChannel

    internal init(channel: FlutterMethodChannel) {
        self.channel = channel
        FRAppDelegate.shared.channel = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "forgerock_authenticator", binaryMessenger: registrar.messenger())
        let instance = SwiftForgerockAuthenticatorPlugin(channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "forgerock_authenticator/events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(FRAppDelegate.shared)
        
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getInitialLink":
            result(FRAppDelegate.shared.initialLink);

        case "hasAlreadyLaunched":
            result(FRAppDelegate.shared.hasAlreadyLaunched);
            
        case "start":
            FRAClientWrapper.shared.startSDK(result: result)

        case "createMechanismFromUri":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let uri = myArgs["uri"] as? String {

                FRAClientWrapper.shared.createMechanismFromUri(uri: uri, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (createMechanismFromUri)", details: nil))
            }

        case "getAllAccounts":
            FRAClientWrapper.shared.getAllAccounts(result: result)

        case "getOathTokenCode":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let identifier = myArgs["mechanismId"] as? String {

                FRAClientWrapper.shared.getOathTokenCode(identifier: identifier, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (getOathTokenCode)", details: nil))
            }

        case "updateAccount":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let accountJson = myArgs["accountJson"] as? String {

                FRAClientWrapper.shared.updateAccount(json: accountJson, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (setStoredAccount)", details: nil))
            }

        case "removeAccount":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let identifier = myArgs["accountId"] as? String {

                FRAClientWrapper.shared.removeAccount(identifier: identifier, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (removeAccount)", details: nil))
            }

        case "removeMechanism":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let identifier = myArgs["mechanismUID"] as? String {

                FRAClientWrapper.shared.removeMechanism(identifier: identifier, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (removeMechanism)", details: nil))
            }

        case "getAllNotificationsByAccountId":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let identifier = myArgs["accountId"] as? String {

                FRAClientWrapper.shared.getAllNotificationsByAccountId(accountId: identifier, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (getAllNotifications)", details: nil))
            }

        case "getAllNotifications":
            FRAClientWrapper.shared.getAllNotifications(result: result)

        case "getNotification":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let notificationId = myArgs["notificationId"] as? String {

                FRAClientWrapper.shared.getNotification(notificationIdentifier: notificationId, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (getNotification)", details: nil))
            }
            
        case "removeAllNotifications":
            FRAClientWrapper.shared.removeAllNotifications(result: result)
            
        case "getPendingNotificationsCount":
            FRAClientWrapper.shared.getPendingNotificationsCount(result: result)

        case "getAllMechanismsGroupByUID":
            FRAClientWrapper.shared.getAllMechanismsGroupByUID(result: result)

        case "handleMessageWithPayload":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let userInfo = myArgs["userInfo"] as? [AnyHashable : Any] {

                FRAClientWrapper.shared.handleMessageWithPayload(userInfo: userInfo, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (handleMessageWithPayload)", details: nil))
            }

        case "performPushAuthentication":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let accept = myArgs["accept"] as? Bool,
               let notificationId = myArgs["notificationId"] as? String {

                FRAClientWrapper.shared.performPushAuthentication(notificationId: notificationId, accept: accept, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (performPushAuthentication)", details: nil))
            }

        case "performPushAuthenticationWithChallenge":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let accept = myArgs["accept"] as? Bool,
               let challengeResponse = myArgs["challengeResponse"] as? String,
               let notificationId = myArgs["notificationId"] as? String {

                FRAClientWrapper.shared.performPushAuthenticationWithChallenge(notificationId: notificationId, challengeResponse: challengeResponse, accept: accept, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (performPushAuthentication)", details: nil))
            }
            
        case "performPushAuthenticationWithBiometric":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let accept = myArgs["accept"] as? Bool,
               let allowDeviceCredentials = myArgs["allowDeviceCredentials"] as? Bool,
               let title = myArgs["title"] as? String,
               let notificationId = myArgs["notificationId"] as? String {

                FRAClientWrapper.shared.performPushAuthenticationWithBiometric(notificationId: notificationId, title: title, allowDeviceCredentials: allowDeviceCredentials, accept: accept, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (performPushAuthentication)", details: nil))
            }
            
        case "getStoredAccount":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let accountId = myArgs["accountId"] as? String {

                FRAClientWrapper.shared.getStoredAccount(accountIdentifier: accountId, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (getStoredAccount)", details: nil))
            }

        case "setStoredAccount":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let accountJson = myArgs["accountJson"] as? String {

                FRAClientWrapper.shared.setStoredAccount(json: accountJson, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (setStoredAccount)", details: nil))
            }

        case "getStoredMechanism":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let mechanismId = myArgs["mechanismId"] as? String {

                FRAClientWrapper.shared.getStoredMechanism(mechanismIdentifier: mechanismId, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (getStoredMechanism)", details: nil))
            }

        case "setStoredMechanism":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let mechanismJson = myArgs["mechanismJson"] as? String {

                FRAClientWrapper.shared.setStoredMechanism(json: mechanismJson, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (setStoredMechanism)", details: nil))
            }

        case "getStoredNotification":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let notificationId = myArgs["notificationId"] as? String {

                FRAClientWrapper.shared.getStoredNotification(notificationIdentifier: notificationId, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (getStoredNotification)", details: nil))
            }

        case "setStoredNotification":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let notificationJson = myArgs["notificationJson"] as? String {

                FRAClientWrapper.shared.setStoredNotification(json: notificationJson, result: result)
            } else {
                result(FlutterError(code: "1", message: "iOS could not recognize flutter arguments in method: (setStoredNotification)", details: nil))
            }

        case "deleteStoredAccount":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let identifier = myArgs["accountId"] as? String {

                FRAClientWrapper.shared.deleteStoredAccount(identifier: identifier, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (deleteStoredAccount)", details: nil))
            }

        case "removeAllData":
            FRAClientWrapper.shared.removeAllData()

        case "getBackup":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let id = myArgs["id"] as? String {

                FRAClientWrapper.shared.getBackup(identifier: id, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (getBackup)", details: nil))
            }

        case "setBackup":
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let id = myArgs["id"] as? String, let jsonData = myArgs["data"] as? String {

                FRAClientWrapper.shared.setBackup(identifier: id, jsonData: jsonData, result: result)
            } else {
                result(FlutterError(code: "PLATAFORM_ARGUMENT_EXCEPTION", message: "iOS could not recognize flutter arguments in method: (setBackup)", details: nil))
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }


    //MARK: - AppDelegate

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        return FRAppDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions as? [UIApplication.LaunchOptionsKey : Any])
    }

    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return FRAppDelegate.shared.application(app, open: url, options: options)
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        return FRAppDelegate.shared.application(application, continue: userActivity, restorationHandler: restorationHandler as! ([UIUserActivityRestoring]?) -> Void)
    }
    
    public func applicationWillResignActive(_ application: UIApplication) {
        FRAppDelegate.shared.applicationWillResignActive(application)
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        FRAppDelegate.shared.applicationDidEnterBackground(application)
    }

    public func applicationWillEnterForeground(_ application: UIApplication) {
        FRAppDelegate.shared.applicationWillEnterForeground(application)
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        FRAppDelegate.shared.applicationDidBecomeActive(application)
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FRAppDelegate.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) -> Void {
        FRAppDelegate.shared.application(application, didReceiveRemoteNotification: userInfo)
    }

    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        FRAppDelegate.shared.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        return true
    }


    //MARK: - NotificationCenter

    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        FRAppDelegate.shared.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        FRAppDelegate.shared.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }

}
