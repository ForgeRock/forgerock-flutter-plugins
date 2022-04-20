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

import androidx.core.app.NotificationManagerCompat;

public class FRANotificationActionReceiver extends BroadcastReceiver {

    private static final String TAG = FRANotificationActionReceiver.class.getSimpleName();

    public static final String ACCEPT_ACTION = "ACCEPT";
    public static final String REJECT_ACTION = "REJECT";
    public static final String MESSAGE_ID_STRING_EXTRA = "MESSAGE_ID";
    public static final String MESSAGE_COUNT_STRING_EXTRA = "MESSAGE_COUNT";

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d(TAG, "Broadcast received for notification action");

        FRAClientWrapper fraClient = FRAClientWrapper
                .getInstanceInBackground(context.getApplicationContext());
        String notificationId = intent.getStringExtra(MESSAGE_ID_STRING_EXTRA);
        PushNotification pushNotification = fraClient.getNotification(notificationId);

        int messageCount = intent.getIntExtra(MESSAGE_COUNT_STRING_EXTRA, 0);
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);

        final String action = intent.getAction();
        if (ACCEPT_ACTION.equals(action)) {
            pushNotification.accept(new FRAListener<Void>() {
                @Override
                public void onSuccess(Void unused) {
                    Log.d(TAG, "Notification successfully approved via system notification action.");
                    notificationManager.cancel(messageCount);
                }

                @Override
                public void onException(Exception e) {
                    Log.e(TAG, "Error approving notification via system notification action.", e);
                }
            });
        } else if (REJECT_ACTION.equals(action)) {
            pushNotification.deny(new FRAListener<Void>() {
                @Override
                public void onSuccess(Void unused) {
                    Log.d(TAG, "Notification successfully rejected via system notification action.");
                    notificationManager.cancel(messageCount);
                }

                @Override
                public void onException(Exception e) {
                    Log.e(TAG, "Error rejecting notification via system notification action.", e);
                }
            });
        } else {
            throw new IllegalArgumentException("Unsupported action: " + action);
        }
    }

}
