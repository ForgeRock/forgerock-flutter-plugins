//
//  Copyright (c) 2022-2023 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation
import FRAuthenticator

class AccountConverter {
    
    static func fromJson(json: String) throws -> Account? {
     
        let account = try JSONDecoder().decode(Account.self, from: json.data(using: .utf8) ?? Data())
        return account
    }

}


