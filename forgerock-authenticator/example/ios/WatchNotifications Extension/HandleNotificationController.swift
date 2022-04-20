//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation
import WatchKit
import UserNotifications

/// Interface controller for showing the details of a notification
class HandleNotificationController: WKInterfaceController {
    
    /// Storyboard identifier for this Interface Controller
    static let identifier = "HandleNotificationController"
    
    @IBOutlet weak var iconImage: WKInterfaceImage!
    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    @IBOutlet weak var acceptButton: WKInterfaceButton!
    @IBOutlet weak var rejectButton: WKInterfaceButton!
    
    /// The notification to display
    private var receivedNotification: NotificationInfo? = nil {
        didSet {
            self.configureUI()
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        debugLog("context: \(context!)")
        
        self.receivedNotification = context as? NotificationInfo
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    /// Configured the UI for displaying the notification, if any
    private func configureUI() {
        if let notification = self.receivedNotification?.notification {
            debugLog("\(notification)")
            
            let userInfo = notification.request.content.userInfo

            guard let aps = userInfo["aps"] as? [String: Any], let message = aps["alert"] as? String else {
                print("Remote-notification is received; however, not a valid format for FRAuthenticator SDK. Ignoring the notification.")
                return
            }
            messageLabel.setText(message)
        }
    }
    
    private func displayLoading() {
        WKExtension.shared().rootInterfaceController?.pop()
        WKExtension.shared().rootInterfaceController?.pushController(withName: LoadingController.identifier, context: nil)
    }
    
    /// Accepts a Push authentication request
    @IBAction func accept() {
        debugLog("accept button pressed")
        self.displayLoading()
        NotificationProcessor.sendNotificationToPhone(approve: true, userInfo: (self.receivedNotification?.notification.request.content.userInfo)!)
    }
    
    /// Reject a Push authentication request
    @IBAction func reject() {
        debugLog("reject button pressed")
        self.displayLoading()
        NotificationProcessor.sendNotificationToPhone(approve: false, userInfo: (self.receivedNotification?.notification.request.content.userInfo)!)
    }
}
