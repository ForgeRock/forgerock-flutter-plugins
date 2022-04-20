//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation
import WatchConnectivity

class WatchSessionManager: NSObject, ObservableObject {
    var session: WCSession
    
    // Singleton for manage only one instance
    static let shared = WatchSessionManager()
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
        debugLog("WCSession started in WatchSessionManager")
    }
    
}

extension WatchSessionManager: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugLog(error)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        debugLog(message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        debugLog(message)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        debugLog(applicationContext)
    }
    
    func sendMessage(for method: String, data: [String: Any] = [:]) {
        debugLog("method: \(method) data: \(data)")
        guard session.isReachable else {
            return
        }
        let messageData: [String: Any] = ["method": method, "data": data]
        session.sendMessage(messageData, replyHandler: nil, errorHandler: nil)
    }
    
    func sendMessage(method: String, data: [String: Any] = [:], replyHandler: (([String : Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        debugLog("method: \(method) data: \(data)")
        guard session.isReachable else {
            return
        }
        let messageData: [String: Any] = ["method": method, "data": data]
        session.sendMessage(messageData, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    func sendApplicationContext(for method: String, data: [String: Any] = [:]) {
        debugLog("method: \(method) data: \(data)")
        do {
            let messageData: [String: Any] = ["method": method, "data": data]
            try session.updateApplicationContext(messageData)
        }
        catch {
            debugLog(error)
        }
    }
    
}


