//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import WatchKit
import Foundation
import SpriteKit

class LoadingController: WKInterfaceController {

    /// Storyboard identifier for this Interface Controller
    static let identifier = "LoadingController"
    
    @IBOutlet weak var progressScene: WKInterfaceSKScene!
    @IBOutlet weak var dismissButton: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let scene: SKScene = SKScene(fileNamed: "ProgressIndicatorScene.sks") {
          debugLog("display loading animation")
          self.progressScene.presentScene(scene, transition: .crossFade(withDuration: 0.1))
        } else {
          debugLog("fail to launch loading animation")
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

    /// Back to main view controller
    @IBAction func backToMainView() {
        debugLog("dismiss button pressed")
//        self.popToRootController()
        WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: InterfaceController.identifier, context: [:] as AnyObject)])
    }
}
