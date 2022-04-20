/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

package org.forgerock.android.auth;

import android.util.Log;

import org.forgerock.android.auth.OathTokenCode;

import java.util.HashMap;

class FRATokenUtil {

    public HashMap<String, Object> toMapObject(OathTokenCode oathTokenCode) {
        HashMap<String, Object> mapToReturn = new HashMap<>();
        mapToReturn.put("code", oathTokenCode.getCurrentCode());
        mapToReturn.put("oathType", oathTokenCode.getOathType().toString());
        mapToReturn.put("start", oathTokenCode.getStart());
        mapToReturn.put("until", oathTokenCode.getUntil());
        return mapToReturn;
    }

}
