//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation
import FRAuthenticator

class OathTokenCodeConverter {
    
    static func toMap(token: OathTokenCode) -> Any {
        var until = 0;
        if token.until != nil {
            until = Int((token.until! * 1000).rounded())
        }
        
        let jsonObject: [String: Any]  = [
            "code": token.code,
            "start": Int((token.start * 1000).rounded()),
            "until": until,
            "oathType": token.tokenType
        ]
        
        return jsonObject
    }
    
}
