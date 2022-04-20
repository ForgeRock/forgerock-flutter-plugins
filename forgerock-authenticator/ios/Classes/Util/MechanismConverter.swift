//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation
import FRAuthenticator

class MechanismConverter {
    
    static let PUSH = "pushauth"
    static let OATH = "otpauth"

    
    static func toJson(mechanism: Mechanism) -> String {
        let jsonObject = mechanismToJson(mechanism: mechanism)
        
        if mechanism is TOTPMechanism, let totp = mechanism as? TOTPMechanism {
            let jsonObject: String = totp.toJson()!
            return jsonObject
        } else if mechanism is HOTPMechanism, let hotp = mechanism as? HOTPMechanism {
            let jsonObject: String = hotp.toJson()!
            return jsonObject
        } else if mechanism is PushMechanism, let push = mechanism as? PushMechanism {
            let jsonObject: String = push.toJson()!
            return jsonObject
        }

        return jsonObject!;
    }
    
    
    static func fromJson(json: String) throws -> Mechanism? {

        let jsonDictionary = ConverterUtil.convertStringToDictionary(jsonString: json)

        let mechanismType : String = jsonDictionary!["type"] as! String
        if mechanismType == "otpauth" {
            let algorithm : String = jsonDictionary!["algorithm"] as! String
            let oathType : String = (jsonDictionary!["oathType"] as! String).lowercased()
            if oathType == "totp" {
                let jsonObject : [String: Any] = [
                    "issuer": jsonDictionary!["issuer"]!,
                    "accountName": jsonDictionary!["accountName"]!,
                    "mechanismUID": jsonDictionary!["mechanismUID"]!,
                    "oathType": oathType,
                    "type": oathType,
                    "secret": jsonDictionary!["secret"]!,
                    "algorithm": algorithm.lowercased(),
                    "digits": jsonDictionary!["digits"]!,
                    "period": jsonDictionary!["period"]!,
                    "timeAdded": Date().millisecondsSince1970
                ]
                let jsonString = ConverterUtil.convertDictionaryToString(dictionary: jsonObject)
                let mechanism = try JSONDecoder().decode(TOTPMechanism.self, from: jsonString!.data(using: .utf8) ?? Data())
                return mechanism
            } else {
                let jsonObject : [String: Any] = [
                    "issuer": jsonDictionary!["issuer"]!,
                    "accountName": jsonDictionary!["accountName"]!,
                    "mechanismUID": jsonDictionary!["mechanismUID"]!,
                    "oathType": oathType,
                    "type": oathType,
                    "secret": jsonDictionary!["secret"]!,
                    "algorithm": algorithm.lowercased(),
                    "digits": jsonDictionary!["digits"]!,
                    "counter": jsonDictionary!["counter"]!,
                    "timeAdded": Date().millisecondsSince1970
                ]
                let jsonString = ConverterUtil.convertDictionaryToString(dictionary: jsonObject)
                let mechanism = try JSONDecoder().decode(HOTPMechanism.self, from: jsonString!.data(using: .utf8) ?? Data())
                return mechanism
            }
        } else if mechanismType == "pushauth" {
            let authenticationEndpoint : String = jsonDictionary!["authenticationEndpoint"] as! String
            let registrationEndpoint = authenticationEndpoint.replacingOccurrences(of: "=authenticate", with: "=register")
            let jsonObject: [String: Any] = [
                "issuer": jsonDictionary!["issuer"]!,
                "accountName": jsonDictionary!["accountName"]!,
                "mechanismUID": jsonDictionary!["mechanismUID"]!,
                "type": mechanismType,
                "secret": jsonDictionary!["secret"]!,
                "authenticationEndpoint": authenticationEndpoint,
                "registrationEndpoint": registrationEndpoint,
                "messageId": "none",
                "challenge": "none",
                "loadBalancer": "none",
                "timeAdded": Date().millisecondsSince1970
            ]
            let jsonString = ConverterUtil.convertDictionaryToString(dictionary: jsonObject)
            let mechanism = try JSONDecoder().decode(PushMechanism.self, from: jsonString!.data(using: .utf8) ?? Data())
            return mechanism
        } else {
            return nil
        }

    }
    
    static func mechanismToJson(mechanism: Mechanism) -> String? {
        if let objData = try? JSONEncoder().encode(mechanism), let serializedStr = String(data: objData, encoding: .utf8) {
            return serializedStr
        }
        else {
            return nil
        }
    }
    
}
