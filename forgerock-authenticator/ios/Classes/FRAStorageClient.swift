//
//  Copyright (c) 2022-2026 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation
import FRCore
import FRAuthenticator

struct FRAStorageClient: StorageClient {
    
    /// The key identifier for storing device token in Keychain
    let deviceTokenIdentifier = "deviceToken"
    
    /// Keychain Service types for all storages in SDK
    enum KeychainStoreType: String {
        case account = ".account"
        case mechanism = ".mechanism"
        case notification = ".notification"
        case pushDeviceToken = ".pushDeviceToken"
        case backup = ".backup"
    }
    
    var accountStorage: KeychainService
    var mechanismStorage: KeychainService
    var notificationStorage: KeychainService
    var pushDeviceTokenStorage: KeychainService
    var backupStorage: KeychainService
    let keychainServiceIdentifier = "com.forgerock.authenticator.keychainservice.local"
    let notificationsMaxSize = 20
    
    init() {
        self.accountStorage = KeychainService(service: keychainServiceIdentifier + KeychainStoreType.account.rawValue)
        self.mechanismStorage = KeychainService(service: keychainServiceIdentifier + KeychainStoreType.mechanism.rawValue)
        self.notificationStorage = KeychainService(service: keychainServiceIdentifier + KeychainStoreType.notification.rawValue)
        self.pushDeviceTokenStorage = KeychainService(service: keychainServiceIdentifier + KeychainStoreType.pushDeviceToken.rawValue)
        self.backupStorage = KeychainService(service: keychainServiceIdentifier + KeychainStoreType.backup.rawValue)
    }
    
    @discardableResult func setAccount(account: Account) -> Bool {
        do {
            let accountData = try NSKeyedArchiver.archivedData(withRootObject: account, requiringSecureCoding: true)
            return self.accountStorage.set(accountData, key: account.identifier)
        }
        catch {
            FRALog.e("Failed to serialize Account object: \(error.localizedDescription)")
            return false
        }
    }
    
    @discardableResult func removeAccount(account: Account) -> Bool {
        return self.accountStorage.delete(account.identifier)
    }
    
    func getAccount(accountIdentifier: String) -> Account? {
        guard let accountData = self.accountStorage.getData(accountIdentifier) else { return nil }
        if let account = try? NSKeyedUnarchiver.unarchivedObject(ofClass: Account.self, from: accountData) {
            return account
        }
        else {
            return nil
        }
    }
    
    func getAllAccounts() -> [Account] {
        var accounts: [Account] = []
        if let items = self.accountStorage.allItems() {
            for item in items {
                if let accountData = item.value as? Data, let account = try? NSKeyedUnarchiver.unarchivedObject(ofClass: Account.self, from: accountData) {
                    accounts.append(account)
                }
            }
        }
        return accounts.sorted { (lhs, rhs) -> Bool in
            return lhs.timeAdded.timeIntervalSince1970 < rhs.timeAdded.timeIntervalSince1970
        }
    }
    
    @discardableResult func setMechanism(mechanism: Mechanism) -> Bool {
        do {
            let mechanismData = try NSKeyedArchiver.archivedData(withRootObject: mechanism, requiringSecureCoding: true)
            return self.mechanismStorage.set(mechanismData, key: mechanism.identifier)
        }
        catch {
            FRALog.e("Failed to serialize Mechanism object: \(error.localizedDescription)")
            return false
        }
    }
    
    @discardableResult func removeMechanism(mechanism: Mechanism) -> Bool {
        return self.mechanismStorage.delete(mechanism.identifier)
    }

    func getMechanismsForAccount(account: Account) -> [Mechanism] {
        var mechanisms: [Mechanism] = []
        if let items = self.mechanismStorage.allItems() {
            for item in items {
                if let mechanismData = item.value as? Data,
                   let mechanism = try? NSKeyedUnarchiver.unarchivedObject(ofClass: Mechanism.self, from: mechanismData) {
                    if mechanism.issuer == account.issuer && mechanism.accountName == account.accountName {
                        mechanisms.append(mechanism)
                    }
                }
            }
        }
        return mechanisms.sorted { (lhs, rhs) -> Bool in
            return lhs.timeAdded.timeIntervalSince1970 < rhs.timeAdded.timeIntervalSince1970
        }
    }
    
    func getAllMechanisms() -> [Mechanism]? {
        var mechanisms: [Mechanism] = []
        if let items = self.mechanismStorage.allItems() {
            for item in items {
                if let mechanismData = item.value as? Data,
                   let mechanism = try? NSKeyedUnarchiver.unarchivedObject(ofClass: Mechanism.self, from: mechanismData) {
                    mechanisms.append(mechanism)
                }
            }
        }
        return mechanisms
    }
    
    func getMechanism(mechanismIdentifier: String) -> Mechanism? {
        let id = getMechanismId(mechanismId: mechanismIdentifier)
        if let mechanismData = self.mechanismStorage.getData(id),
           let mechanism = try? NSKeyedUnarchiver.unarchivedObject(ofClass: Mechanism.self, from: mechanismData) {
            return mechanism
        }
        else {
            return nil
        }
    }
    
    private func getMechanismId(mechanismId: String) -> String {
        return mechanismId.replacingOccurrences(of: "#", with: "-")
    }
    
    func getMechanismForUUID(uuid: String) -> Mechanism? {
        if let items = self.mechanismStorage.allItems() {
            for item in items {
                if let mechanismData = item.value as? Data,
                   let mechanism = try? NSKeyedUnarchiver.unarchivedObject(ofClass: Mechanism.self, from: mechanismData) {
                    if mechanism.mechanismUUID == uuid {
                        return mechanism
                    }
                }
            }
        }
        return nil
    }
    
    func getAllMechanismsGroupByUID() -> [String: Any]? {
        var mechanismMap: [String: Any] = [:]
        if let items = self.mechanismStorage.allItems() {
            for item in items {
                if let mechanismData = item.value as? Data,
                   let mechanism = try? NSKeyedUnarchiver.unarchivedObject(ofClass: Mechanism.self, from: mechanismData) {
                    mechanismMap[mechanism.mechanismUUID] = MechanismConverter.toJson(mechanism:mechanism)
                }
            }
        }
        return mechanismMap
    }
        
    @discardableResult func setNotification(notification: PushNotification) -> Bool {
        do {
            let notificationData = try NSKeyedArchiver.archivedData(withRootObject: notification, requiringSecureCoding: true)
            return self.notificationStorage.set(notificationData, key: notification.identifier)
        }
        catch {
            FRALog.e("Failed to serialize PushNotification object: \(error.localizedDescription)")
            return false
        }
    }
        
    @discardableResult func removeNotification(notification: PushNotification) -> Bool {
        return self.notificationStorage.delete(notification.identifier)
    }
    
    @discardableResult func removeAllNotifications() -> Bool {
        return self.notificationStorage.deleteAll()
    }
    
    func getNotification(notificationIdentifier: String) -> PushNotification? {
        guard let notificationData = self.notificationStorage.getData(notificationIdentifier) else { return nil }
        if let notification = try? NSKeyedUnarchiver.unarchivedObject(ofClass: PushNotification.self, from: notificationData) {
            return notification
        }
        else {
            return nil
        }
    }
    
    func getAllNotificationsForMechanism(mechanism: Mechanism) -> [PushNotification] {
        var notifications: [PushNotification] = []
        if let items = self.notificationStorage.allItems() {
           for item in items {
               if let notificationData = item.value as? Data,
                  let notification = try? NSKeyedUnarchiver.unarchivedObject(ofClass: PushNotification.self, from: notificationData),
                notification.mechanismUUID == mechanism.mechanismUUID {
                   notifications.append(notification)
               }
           }
        }
        return notifications.sorted { (lhs, rhs) -> Bool in
            return lhs.timeAdded.timeIntervalSince1970 < rhs.timeAdded.timeIntervalSince1970
        }
    }
    
    func getAllNotifications() -> [PushNotification] {
        var notifications: [PushNotification] = []
        if let items = self.notificationStorage.allItems() {
           for item in items {
               if let notificationData = item.value as? Data, let notification = try? NSKeyedUnarchiver.unarchivedObject(ofClass: PushNotification.self, from: notificationData) {
                   notifications.append(notification)
               }
           }
        }
        notifications = notifications.sorted { (lhs, rhs) -> Bool in
            return lhs.timeAdded.timeIntervalSince1970 > rhs.timeAdded.timeIntervalSince1970
        }
        return self.removeOldNotificationEntries(notifications: &notifications)
    }
    
    func getNotificationByMessageId(messageId: String) -> PushNotification? {
        if let items = self.notificationStorage.allItems() {
           for item in items {
               if let notificationData = item.value as? Data,
                  let notification = try? NSKeyedUnarchiver.unarchivedObject(ofClass: PushNotification.self, from: notificationData),
                  notification.messageId == messageId {
                   return notification
               }
           }
        }
        
        return nil
    }
    
    private func removeOldNotificationEntries(notifications: inout [PushNotification])  -> [PushNotification] {
        FRALog.v("Checking old PushNotification entries to remove...")
        var removedEntries = 0
        while (notifications.count > notificationsMaxSize) {
            self.removeNotification(notification: notifications.last!)
            notifications.removeLast()
            removedEntries+=1
        }
        FRALog.v("\(removedEntries) PushNotification entries removed.")
        return notifications
    }
    
    @discardableResult func setPushDeviceToken(pushDeviceToken: PushDeviceToken) -> Bool {
        do {
            let pushDeviceTokenData = try NSKeyedArchiver.archivedData(withRootObject: pushDeviceToken, requiringSecureCoding: true)
            return self.pushDeviceTokenStorage.set(pushDeviceTokenData, key: deviceTokenIdentifier)
        }
        catch {
            FRALog.e("Failed to serialize PushDeviceToken object: \(error.localizedDescription)")
            return false
        }
    }
    
    
    func getPushDeviceToken() -> PushDeviceToken? {
        guard let pushDeviceTokenData = self.pushDeviceTokenStorage.getData(deviceTokenIdentifier) else { return nil }
        if let pushDeviceToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: PushDeviceToken.self, from: pushDeviceTokenData) {
            return pushDeviceToken
        }
        else {
            return nil
        }
    }
    
    
    @discardableResult func removePushDeviceToken() -> Bool {
        return self.pushDeviceTokenStorage.delete(deviceTokenIdentifier)
    }
    
    @discardableResult func isEmpty() -> Bool {
        return self.notificationStorage.allItems()?.count == 0 && self.mechanismStorage.allItems()?.count == 0 && self.accountStorage.allItems()?.count == 0
    }
    
    func removeAllData() {
        let secItemClasses = [kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity]
        for secItemClass in secItemClasses {
            let query: NSDictionary = [
                kSecClass as String: secItemClass,
                kSecAttrSynchronizable as String: kSecAttrSynchronizableAny
            ]
            SecItemDelete(query)
        }
    }
    
    func getBackup(identifier: String) -> String? {
        if let backupData = self.backupStorage.getData(identifier),
           let data = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSString.self, from: backupData) {
            return data as String
        }
        else {
            return nil
        }
    }
    
    @discardableResult func setBackup(identifier: String, jsonData: String) -> Bool {
        do {
            let backupData = try NSKeyedArchiver.archivedData(withRootObject: jsonData as NSString, requiringSecureCoding: true)
            return self.backupStorage.set(backupData, key: identifier)
        }
        catch {
            FRALog.e("Failed to serialize String object: \(error.localizedDescription)")
            return false
        }
    }
    
}
