//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import WatchKit
import Foundation


class ResultController: WKInterfaceController {

    @IBOutlet weak var dismissButton: WKInterfaceButton!
    @IBOutlet weak var messageImage: WKInterfaceImage!
    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    
    private var result : Bool = true {
        didSet {
            self.configureUI()
        }
    }
    
    /// Storyboard identifier for this Interface Controller
    static let identifier = "ResultController"
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        debugLog("context: \(context!)")
        
        if let conextResult = context as? [String : Any], let result = conextResult["result"] as? Bool {
            self.result = result
        } else {
            self.result = false
        }
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
        if(self.result) {
            let image = UIImage(systemName: "person.crop.circle.badge.checkmark")
            messageImage.setImage(image)
            messageImage.setTintColor(UIColor(red: 3/255, green: 43/255, blue: 117/255, alpha: 1))
            messageLabel.setText("Authentication request sucessfully processed.")
        } else {
            let image = UIImage(systemName: "person.crop.circle.badge.exclamationmark")
            messageImage.setImage(image)
            messageImage.setTintColor(UIColor.red)
            messageLabel.setText("Could not process authentication request.")
        }
    }
    
    /// Back to main view controller
    @IBAction func backToMainView() {
        debugLog("dismiss button pressed")
//        self.popToRootController()
        WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: InterfaceController.identifier, context: [:] as AnyObject)])
    }
    
}
