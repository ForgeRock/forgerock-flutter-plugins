//
//  Copyright (c) 2022-2023 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation
import FRCore
import FRAuthenticator

struct FRAStorageClient: StorageClient {
    
    /// Keychain Service types for all storages in SDK
    enum KeychainStoreType: String {
        case account = ".account"
        case mechanism = ".mechanism"
        case notification = ".notification"
        case backup = ".backup"
        case token = ".token"
    }
    
    var accountStorage: KeychainService
    var mechanismStorage: KeychainService
    var notificationStorage: KeychainService
    var backupStorage: KeychainService
    var tokenStorage: KeychainService
    let keychainServiceIdentifier = "com.forgerock.authenticator.keychainservice.local"
    let tokenKey = "token"
    let notificationsMaxSize = 20
    
    init() {
        self.accountStorage = KeychainService(service: keychainServiceIdentifier + KeychainStoreType.account.rawValue)
        self.mechanismStorage = KeychainService(service: keychainServiceIdentifier + KeychainStoreType.mechanism.rawValue)
        self.notificationStorage = KeychainService(service: keychainServiceIdentifier + KeychainStoreType.notification.rawValue)
        self.backupStorage = KeychainService(service: keychainServiceIdentifier + KeychainStoreType.backup.rawValue)
        self.tokenStorage = KeychainService(service: keychainServiceIdentifier + KeychainStoreType.token.rawValue)
    }
    
    @discardableResult func setAccount(account: Account) -> Bool {
        if #available(iOS 11.0, *) {
            do {
                let accountData = try NSKeyedArchiver.archivedData(withRootObject: account, requiringSecureCoding: true)
                return self.accountStorage.set(accountData, key: account.identifier)
            }
            catch {
                FRALog.e("Failed to serialize Account object: \(error.localizedDescription)")
                return false
            }
        } else {
            let accountData = NSKeyedArchiver.archivedData(withRootObject: account)
            return self.accountStorage.set(accountData, key: account.identifier)
        }
    }
    
    @discardableResult func removeAccount(account: Account) -> Bool {
        return self.accountStorage.delete(account.identifier)
    }
    
    func getAccount(accountIdentifier: String) -> Account? {
        if let accountData = self.accountStorage.getData(accountIdentifier),
            let account = NSKeyedUnarchiver.unarchiveObject(with: accountData) as? Account {
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
                if let accountData = item.value as? Data, let account = NSKeyedUnarchiver.unarchiveObject(with: accountData) as? Account {
                    accounts.append(account)
                }
            }
        }
        return accounts.sorted { (lhs, rhs) -> Bool in
            return lhs.timeAdded.timeIntervalSince1970 < rhs.timeAdded.timeIntervalSince1970
        }
    }
    
    @discardableResult func setMechanism(mechanism: Mechanism) -> Bool {
        if #available(iOS 11.0, *) {
            do {
                let mechanismData = try NSKeyedArchiver.archivedData(withRootObject: mechanism, requiringSecureCoding: true)
                return self.mechanismStorage.set(mechanismData, key: mechanism.identifier)
            }
            catch {
                FRALog.e("Failed to serialize Mechanism object: \(error.localizedDescription)")
                return false
            }
        } else {
            let mechanismData = NSKeyedArchiver.archivedData(withRootObject: mechanism)
            return self.mechanismStorage.set(mechanismData, key: mechanism.identifier)
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
                let mechanism = NSKeyedUnarchiver.unarchiveObject(with: mechanismData) as? Mechanism {
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
                let mechanism = NSKeyedUnarchiver.unarchiveObject(with: mechanismData) as? Mechanism {
                    mechanisms.append(mechanism)
                }
            }
        }
        return mechanisms
    }
    
    func getMechanism(mechanismIdentifier: String) -> Mechanism? {
        let id = getMechanismId(mechanismId: mechanismIdentifier)
        if let mechanismData = self.mechanismStorage.getData(id),
            let mechanism = NSKeyedUnarchiver.unarchiveObject(with: mechanismData) as? Mechanism {
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
                let mechanism = NSKeyedUnarchiver.unarchiveObject(with: mechanismData) as? Mechanism {
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
                let mechanism = NSKeyedUnarchiver.unarchiveObject(with: mechanismData) as? Mechanism {
                    mechanismMap[mechanism.mechanismUUID] = MechanismConverter.toJson(mechanism:mechanism)
                }
            }
        }
        return mechanismMap
    }
        
    @discardableResult func setNotification(notification: PushNotification) -> Bool {
        if #available(iOS 11.0, *) {
            do {
                let notificationData = try NSKeyedArchiver.archivedData(withRootObject: notification, requiringSecureCoding: true)
                return self.notificationStorage.set(notificationData, key: notification.identifier)
            }
            catch {
                FRALog.e("Failed to serialize PushNotification object: \(error.localizedDescription)")
                return false
            }
        } else {
            let notificationData = NSKeyedArchiver.archivedData(withRootObject: notification)
            return self.notificationStorage.set(notificationData, key: notification.identifier)
        }
    }
        
    @discardableResult func removeNotification(notification: PushNotification) -> Bool {
        return self.notificationStorage.delete(notification.identifier)
    }
    
    @discardableResult func removeAllNotifications() -> Bool {
        return self.notificationStorage.deleteAll()
    }
    
    func getNotification(notificationIdentifier: String) -> PushNotification? {
        if let notificationData = self.notificationStorage.getData(notificationIdentifier),
            let notification = NSKeyedUnarchiver.unarchiveObject(with: notificationData) as? PushNotification {
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
                let notification = NSKeyedUnarchiver.unarchiveObject(with: notificationData) as? PushNotification,
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
               if let notificationData = item.value as? Data, let notification = NSKeyedUnarchiver.unarchiveObject(with: notificationData) as? PushNotification {
                   notifications.append(notification)
               }
           }
        }
        notifications = notifications.sorted { (lhs, rhs) -> Bool in
            return lhs.timeAdded.timeIntervalSince1970 > rhs.timeAdded.timeIntervalSince1970
        }
        return self.removeOldNotificationEntries(notifications: &notifications)
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
            let data = NSKeyedUnarchiver.unarchiveObject(with: backupData) as? String {
            return data
        }
        else {
            return nil
        }
    }
    
    @discardableResult func setBackup(identifier: String, jsonData: String) -> Bool {
        if #available(iOS 11.0, *) {
            do {
                let backupData = try NSKeyedArchiver.archivedData(withRootObject: jsonData, requiringSecureCoding: true)
                return self.backupStorage.set(backupData, key: identifier)
            }
            catch {
                FRALog.e("Failed to serialize String object: \(error.localizedDescription)")
                return false
            }
        } else {
            let backupData = NSKeyedArchiver.archivedData(withRootObject: jsonData)
            return self.backupStorage.set(backupData, key: identifier)
        }
    }

    @discardableResult func setToken(token: String) -> Bool {
        if #available(iOS 11.0, *) {
            do {
                let tokenData = try NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
                return self.tokenStorage.set(tokenData, key: tokenKey)
            }
            catch {
                FRALog.e("Failed to serialize Token object: \(error.localizedDescription)")
                return false
            }
        } else {
            let tokenData = NSKeyedArchiver.archivedData(withRootObject: token)
            return self.tokenStorage.set(tokenData, key: tokenKey)
        }
    }
    
    func getToken() -> String? {
        if let tokenData = self.tokenStorage.getData(tokenKey),
           let data = NSKeyedUnarchiver.unarchiveObject(with: tokenData) as? String {
            return data
        }
        else {
            return nil
        }
    }
    
}
