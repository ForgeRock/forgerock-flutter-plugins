//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation
import FRAuthenticator

class AccountConverter {
    
    static func toMap(account: Account) -> Any {
        
        var tmpMechanisms: [Any] = []
        for mechanism in account.mechanisms {
            let convertedMechanism = MechanismConverter.toJson(mechanism: mechanism)
            tmpMechanisms.append(convertedMechanism)
        }
        
        let jsonObject: [String: Any]  = [
            "id": account.identifier,
            "issuer": account.issuer,
            "displayIssuer": account.displayIssuer,
            "accountName": account.accountName,
            "displayAccountName": account.displayAccountName,
            "imageURL": account.imageUrl,
            "timeAdded": account.timeAdded.millisecondsSince1970,
            "mechanismList" : tmpMechanisms
        ]
        
        return jsonObject
    }
    
    static func fromJson(json: String) throws -> Account? {
     
        let account = try JSONDecoder().decode(Account.self, from: json.data(using: .utf8) ?? Data())
        return account
    }


}


