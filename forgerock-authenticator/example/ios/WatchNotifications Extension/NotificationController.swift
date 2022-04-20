//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import WatchKit
import Foundation
import UserNotifications

class NotificationController: WKUserNotificationInterfaceController {

    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    
    /// The notification to display
    private var receivedNotification: UNNotification? = nil {
        didSet {
            debugLog("receivedNotification: \(receivedNotification!)")
            self.configureUI()
        }
    }
    
    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }
    
    /// Configured the UI for displaying the notification, if any
    private func configureUI() {
        debugLog()
        if let notification = self.receivedNotification {
            let userInfo = notification.request.content.userInfo
            
            guard let aps = userInfo["aps"] as? [String: Any], let message = aps["alert"] as? String else {
                debugLog("Remote-notification is received; however, not a valid format for FRAuthenticator SDK. Ignoring the notification.")
                return
            }

            messageLabel.setText(message)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

    override func didReceive(_ notification: UNNotification) {
        // This method is called when a notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        
        debugLog("notification: \(notification)")
        self.receivedNotification = notification
    }
}
