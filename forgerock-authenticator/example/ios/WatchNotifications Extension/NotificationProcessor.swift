//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import WatchKit
import UserNotifications

/// Notification categories supported by the application
enum UserNotificationCategory: String {
    /// Authentcation category
    case authentication
}

/// Notification actions supported by the application
enum UserNotificationAction: String {
    /// Action that should accept and authentication request
    case ACCEPT_ACTION
    /// Action that should reject and authentication request
    case DECLINE_ACTION
}

/// The Notification Processor handles the details of updating the application status for recevied and processed notifications
/// Handling the logic in a dedicate class / `UNUserNotificationCenterDelegate` instance avoids the scenario of notifications
/// coming in before any Interface Controllers are loaded/
class NotificationProcessor: NSObject {
    
    /// Registers for known notification categories.
    ///
    /// - Note: These notification categories and actions **only** apply to notifications schedules on-Watch.
    func registerNotifications() {
        debugLog("registerNotifications")
        
        let acceptAction = UNNotificationAction(
            identifier: UserNotificationAction.ACCEPT_ACTION.rawValue,
            title: NSLocalizedString("Accept", comment: "Accept the authentocation request"),
            options: [.foreground])
        
        let declineAction = UNNotificationAction(
            identifier: UserNotificationAction.DECLINE_ACTION.rawValue,
            title: NSLocalizedString("Reject", comment: "Reject the authentocation request"),
            options: [.foreground])
        
        let authenticationCategory = UNNotificationCategory(
            identifier: UserNotificationCategory.authentication.rawValue,
            actions: [acceptAction, declineAction],
            intentIdentifiers: [],
            options: [])

        let categories: Set<UNNotificationCategory> = [authenticationCategory]
        
        UNUserNotificationCenter.current().setNotificationCategories(categories)
    }
    
    /// Updates the application state with the given notification
    ///
    /// - Parameters:
    ///   - notification: The notification being processed
    ///   - action: The action, if any, associated with the notification
    fileprivate func process(notification: UNNotification, with response: UNNotificationResponse? = nil) {
        let notificationInfo = NotificationInfo(notification: notification, response: response)
        if notificationInfo.category == UserNotificationCategory.authentication {
            // Handle notification with category
            debugLog("Handle notification with category")
            switch notificationInfo.action?.rawValue {
            case UserNotificationAction.ACCEPT_ACTION.rawValue:
                debugLog("action: ACCEPT_ACTION")
                NotificationProcessor.sendNotificationToPhone(approve: true, userInfo: notification.request.content.userInfo)
                WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: LoadingController.identifier, context: [:] as AnyObject)])
              break
                     
            case UserNotificationAction.DECLINE_ACTION.rawValue:
                debugLog("action: DECLINE_ACTION")
                NotificationProcessor.sendNotificationToPhone(approve: false, userInfo: notification.request.content.userInfo)
                WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: LoadingController.identifier, context: [:] as AnyObject)])
              break
                 
            case UNNotificationDefaultActionIdentifier, UNNotificationDismissActionIdentifier:
              break
                     
            default:
              break
           }
        }
        else {
            // Handle other notification types...
            debugLog("Handle notification with NO category")
            WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: HandleNotificationController.identifier, context: notificationInfo as AnyObject)])
        }
    }
    
    static func sendNotificationToPhone(approve: Bool, userInfo: [AnyHashable : Any] = [:]) {
        let data = [
            "approve" : approve,
            "userInfo" : userInfo
        ] as [String : Any]
        
        WatchSessionManager.shared.sendMessage(method: "sendNotificationToPhone", data:data, replyHandler: { (response) in
            debugLog("reply: \(response)")

            DispatchQueue.main.async {
                WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: ResultController.identifier, context: response as AnyObject)])
            }
        }) { (error) in
            debugLog("Error sending message: \(error)")
        }

    }
    
}

extension NotificationProcessor: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        debugLog("process received notification")

        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // When a custom interface is defined and the notification body is tapped, this method appears to be called twice.
        // Once with the UNNotificationDefaultActionIdentifier action and once with an empty string for the action.
        // Filter out the empty string call to prevent duplicate notification processing.
        guard !response.actionIdentifier.isEmpty else { return }
        
        debugLog("Notification Category: \(response.notification.request.content.categoryIdentifier)")
        debugLog("Action Identifier: \(response.actionIdentifier)");
        debugLog("\(#function) - action = \(response.actionIdentifier) (\(response.actionIdentifier.count))")
        self.process(notification: response.notification, with: response)
        
        completionHandler()
    }
}

/// Structure that wraps the required info for reacting to a notification response
struct NotificationInfo {
    /// The notification that triggered the response
    let notification: UNNotification
    /// The notification response
    let response: UNNotificationResponse?
    
    /// The category of the notification
    var category: UserNotificationCategory? {
        return response.flatMap { UserNotificationCategory(rawValue: $0.notification.request.content.categoryIdentifier ) }
    }
    
    /// The action in the response
    var action: UserNotificationAction? {
        return response.flatMap { UserNotificationAction(rawValue: $0.actionIdentifier ) }
    }
    
    /// The action in the response
    var userInfo: [AnyHashable : Any]? {
        return response?.notification.request.content.userInfo
    }
}
