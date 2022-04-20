/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

package org.forgerock.android.auth;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.google.firebase.messaging.RemoteMessage;

import java.util.HashMap;

public class FRAMessagingReceiver extends BroadcastReceiver {
    private static final String TAG = FRAMessagingReceiver.class.getSimpleName();
    private static final String MESSAGE = "message";
    private static final String MESSAGE_ID = "messageId";

    static HashMap<String, RemoteMessage> notifications = new HashMap<>();

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d(TAG, "broadcast received for message");

        FRAMessagingUtil.setApplicationContext(context.getApplicationContext());

        if (intent.getExtras() == null) {
            Log.d(TAG,"broadcast received but intent contained no extras to process RemoteMessage. Operation cancelled.");
            return;
        }

        RemoteMessage remoteMessage = new RemoteMessage(intent.getExtras());
        Log.d(TAG, "RemoteMessage Data: " + remoteMessage.getData());

        // Process the RemoteMessage if the message contains a notification payload.
        if (remoteMessage.getData().get(MESSAGE) != null) {
            notifications.put(remoteMessage.getMessageId(), remoteMessage);

            // Send remote message received to be processed by the Authenticator SDK
            PushNotification pushNotification =  FRAClientWrapper
                    .getInstance(context.getApplicationContext())
                    .handleMessage(remoteMessage.getData().get(MESSAGE_ID), remoteMessage.getData().get(MESSAGE));

            // If it's a valid Push message from AM, create a system notification
            if(pushNotification != null && !FRAMessagingUtil.isApplicationForeground(context)) {
                Log.d(TAG, "Creating system notification...");
                FRAMessagingUtil.createSystemNotification(pushNotification);
            } else {
                Log.d(TAG, "Failed to process Push Notification. System notification not created.");
            }
        } else {
            Log.d(TAG, "Failed to obtain RemoteMessage from intent.");
        }
    }

}

