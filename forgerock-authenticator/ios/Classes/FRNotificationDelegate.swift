//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation

extension FRAppDelegate: UNUserNotificationCenterDelegate {
    
    //MARK: - Push Notifications Handler

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

    /// Register app for remote notifications, set notifications categories and update badge number
    func setupNotifications() {
        let application = UIApplication.shared
        let center = UNUserNotificationCenter.current()

        // check notification permissions
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if let error = error {
                NSLog(error.localizedDescription)
                return
            }
        }
        application.registerForRemoteNotifications()

        // register notification categories
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
        center.setNotificationCategories(categories)

        // update app icon unread count to 1 if there is a pending notification
        application.applicationIconBadgeNumber = FRAClientWrapper.shared.pendingNotificationsCount()
    }
    
    
    //MARK: - NotificationCenter

    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NSLog("userNotificationCenter:willPresent:withCompletionHandler:userInfo: \(notification.request.content.userInfo)")

        let userInfo = notification.request.content.userInfo
        guard userInfo["aps"] != nil else {
            return
        }

        completionHandler([.alert, .sound])
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NSLog("userNotificationCenter:didReceive:withCompletionHandler:userInfo: \(response.notification.request.content.userInfo)")

        let userInfo = response.notification.request.content.userInfo
        guard userInfo["aps"] != nil else {
            return
        }

        let notification = FRAClientWrapper.shared.handleMessageWithPayload(userInfo: userInfo)
        let action = response.actionIdentifier
        let category = response.notification.request.content.categoryIdentifier

        if (category == UserNotificationCategory.authentication.rawValue) {
            NSLog("Handle notification with category=\(category) and action=\(action)")
            switch action {
                case UserNotificationAction.ACCEPT_ACTION.rawValue:
                FRAClientWrapper.shared.performPushAuthentication(notificationId: notification!.identifier, accept: true, result: nil)
                  break

                case UserNotificationAction.DECLINE_ACTION.rawValue:
                FRAClientWrapper.shared.performPushAuthentication(notificationId: notification!.identifier, accept: false, result: nil)
                  break

                case UNNotificationDefaultActionIdentifier, UNNotificationDismissActionIdentifier:
                  break

                default:
                  break
           }
        }

        completionHandler()
    }
    
    /// Process any pending notification from Notification Center not delivered to the app
    func processPendingDeliveredNotifications() {
        let center = UNUserNotificationCenter.current()

        center.getDeliveredNotifications { (receivedNotifications) in
            for notification in receivedNotifications {
                let notificationDate = notification.date
                let notificationExpireDate = notificationDate.addingTimeInterval(2*60)
                let now : Date = Date()
                let userInfo = notification.request.content.userInfo

                // by default, notifications expires in 2 minutes. If it is not expired, handle the notification
                NSLog("getDeliveredNotifications - userInfo: \(userInfo): date: \(notificationDate)")
                if now < notificationExpireDate {
                    FRAClientWrapper.shared.handleMessageWithPayload(userInfo: userInfo)
                } else {
                    NSLog("Notification expired, will not be processed by the SDK.")
                }
            }
        }
    }

}
