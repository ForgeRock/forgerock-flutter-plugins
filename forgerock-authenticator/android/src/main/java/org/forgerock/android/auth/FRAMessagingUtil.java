/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

package org.forgerock.android.auth;

import android.app.ActivityManager;
import android.app.KeyguardManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import org.forgerock.forgerock_authenticator.R;

import java.util.List;

class FRAMessagingUtil {

    private static final String TAG = FRAMessagingUtil.class.getSimpleName();

    private static Context applicationContext;
    private static int messageCount = 1;
    private static final Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);

    /**
     * Sets the application context.
     * @param applicationContext application context.
     */
    static void setApplicationContext(Context applicationContext) {
        Log.d(TAG, "Received application context.");
        FRAMessagingUtil.applicationContext = applicationContext;
    }

    /**
     * Identify if the application is currently in a state where user interaction is possible. This
     * method is called when a remote message is received to determine how the incoming message should
     * be handled.
     *
     * @param context context.
     * @return True if the application is currently in a state where user interaction is possible,
     *     false otherwise.
     */
    static boolean isApplicationForeground(Context context) {
        KeyguardManager keyguardManager =
                (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);

        if (keyguardManager != null && keyguardManager.isKeyguardLocked()) {
            return false;
        }

        ActivityManager activityManager =
                (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        if (activityManager == null) return false;

        List<ActivityManager.RunningAppProcessInfo> appProcesses =
                activityManager.getRunningAppProcesses();
        if (appProcesses == null) return false;

        final String packageName = context.getPackageName();
        for (ActivityManager.RunningAppProcessInfo appProcess : appProcesses) {
            if (appProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
                    && appProcess.processName.equals(packageName)) {
                return true;
            }
        }

        return false;
    }

    /***
     * Create a system notification for the Push Notification received. If the notification type
     * is {@code PushType.DEFAULT}, it display actions to approve or reject the notification.
     *
     * @param context context.
     * @param pushNotification the PushNotification to be processed.
     */
    static void createSystemNotification(Context context, PushNotification pushNotification) {
        int id = messageCount++;

        if (context == null) {
            context = applicationContext;
        }

        Notification notification = buildNotification(context, id, pushNotification);
        Log.d(TAG, "System notification created.");
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
        notificationManager.notify(id, notification);
    }

    private static Notification buildNotification(Context context, int requestCode, PushNotification pushNotification) {
        Log.d(TAG, "Building notification...");
        createNotificationChannel(context);

        int intentFlags = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                ? PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                : PendingIntent.FLAG_UPDATE_CURRENT;

        Intent intent = getLaunchIntent(context);
        PendingIntent contentIntent = PendingIntent.getActivity(context, requestCode, intent, intentFlags);

        String title = getTitle(context, pushNotification);
        String body = getBody(context, pushNotification);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, context.getString(R.string.channel_id))
                .setSmallIcon(R.drawable.forgerock_notification)
                .setContentTitle(title)
                .setContentText(body)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setSound(defaultSoundUri)
                .setContentIntent(contentIntent);

        if (pushNotification.getPushType() == PushType.DEFAULT) {
            Intent acceptIntent = new Intent(context, FRANotificationActionReceiver.class);
            acceptIntent.setAction(FRANotificationActionReceiver.ACCEPT_ACTION);
            acceptIntent.putExtra(FRANotificationActionReceiver.MESSAGE_ID_STRING_EXTRA,
                    pushNotification.getId());
            acceptIntent.putExtra(FRANotificationActionReceiver.MESSAGE_COUNT_STRING_EXTRA,
                    requestCode);
            PendingIntent acceptPendingIntent = PendingIntent.getBroadcast(context,
                    0, acceptIntent, intentFlags);

            Intent rejectIntent = new Intent(context, FRANotificationActionReceiver.class);
            rejectIntent.setAction(FRANotificationActionReceiver.REJECT_ACTION);
            rejectIntent.putExtra(FRANotificationActionReceiver.MESSAGE_ID_STRING_EXTRA,
                    pushNotification.getId());
            rejectIntent.putExtra(FRANotificationActionReceiver.MESSAGE_COUNT_STRING_EXTRA,
                    requestCode);
            PendingIntent rejectPendingIntent = PendingIntent.getBroadcast(context,
                    0, rejectIntent, intentFlags);

            builder.addAction(0, context.getString(R.string.system_notification_action_approve),
                    acceptPendingIntent);
            builder.addAction(0, context.getString(R.string.system_notification_action_deny),
                    rejectPendingIntent);
        }

        return builder.build();
    }

    private static void createNotificationChannel(Context context){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Log.d(TAG, "Creating notification channel.");
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            String channelId = context.getString(R.string.channel_id);
            String channelName = context.getString(R.string.channel_name);
            NotificationChannel channel = new NotificationChannel(channelId, channelName, importance);
            NotificationManager notificationManager = context.getSystemService(NotificationManager.class);
            if (notificationManager != null) {
                notificationManager.createNotificationChannel(channel);
            }
        }
    }

    private static String getTitle(Context context, PushNotification pushNotification) {
        if (pushNotification.getMessage() != null) {
            return pushNotification.getMessage();
        } else {
            Mechanism mechanism = FRAClientWrapper
                    .getInstanceInBackground(context)
                    .getMechanism(pushNotification);
            return String.format(context.getString(R.string.system_notification_title),
                    mechanism.getAccountName(), mechanism.getIssuer());
        }
    }

    private static String getBody(Context context, PushNotification pushNotification) {
        if (pushNotification.getPushType() == PushType.DEFAULT) {
            return context.getString(R.string.system_notification_body_with_actions);
        } else {
            return context.getString(R.string.system_notification_body);
        }
    }

    private static Intent getLaunchIntent(Context context) {
        String packageName = context.getPackageName();
        PackageManager packageManager = context.getPackageManager();
        return packageManager.getLaunchIntentForPackage(packageName);
    }
}
