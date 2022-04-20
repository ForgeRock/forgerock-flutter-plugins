//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import Foundation
import FRAuthenticator

class PushNotificationConverter {

    static func fromJson(json: String) throws -> PushNotification? {
     
        let pushNotification = try JSONDecoder().decode(PushNotification.self, from: json.data(using: .utf8) ?? Data())
        return pushNotification
    }
    
}
