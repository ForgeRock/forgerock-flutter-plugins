/*
 * Copyright (c) 2022-2026 ForgeRock. All rights reserved.
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

        // Update the device token in the FRAClientWrapper
        FRAClientWrapper.getInstanceInBackground(getApplicationContext()).updateDeviceToken(s);
    }

}
