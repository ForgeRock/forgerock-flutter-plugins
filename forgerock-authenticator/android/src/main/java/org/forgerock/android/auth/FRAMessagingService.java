/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

package org.forgerock.android.auth;

import androidx.annotation.NonNull;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class FRAMessagingService extends FirebaseMessagingService {

    @Override
    public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
        // This FCM method does not handle the message here as it is already handled in the receiver
    }

    @Override
    public void onNewToken(@NonNull String s) {
        super.onNewToken(s);

        // This FCM method is called if InstanceID token is updated. This may occur if the security
        // of the previous token had been compromised.
        // Currently OpenAM does not provide an API to receives updates for those tokens. So, there
        // is no method available to handle it FRAClient. The current workaround is removed the Push
        // mechanism and add it again by scanning a new QRCode.
    }

}
