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

    static void setApplicationContext(Context applicationContext) {
        Log.d(TAG, "received application context.");
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

    static void createSystemNotification(PushNotification pushNotification) {
        int id = messageCount++;

        Mechanism mechanism = FRAClientWrapper
                .getInstance(applicationContext)
                .getMechanism(pushNotification);

        String title = String.format(applicationContext.getString(R.string.system_notification_title),
                mechanism.getAccountName(), mechanism.getIssuer());
        String body = applicationContext.getString(R.string.system_notification_body);

        Notification notification = generatePending(applicationContext, id, title, body);

        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(applicationContext);
        notificationManager.notify(id, notification);
    }

    private static Notification generatePending(Context context, int requestCode, String title, String message) {
        createNotificationChannel(context);
        Intent intent = getLaunchIntent(applicationContext);
        PendingIntent pendingIntent;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            pendingIntent = PendingIntent.getActivity(context, requestCode, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        }else {
            pendingIntent = PendingIntent.getActivity(context, requestCode, intent, PendingIntent.FLAG_UPDATE_CURRENT);
        }
        return new NotificationCompat.Builder(context, context.getString(R.string.channel_id))
                .setSmallIcon(R.drawable.forgerock_notification)
                .setContentTitle(title)
                .setContentText(message)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setSound(defaultSoundUri)
                .setContentIntent(pendingIntent)
                .build();
    }

    private static void createNotificationChannel(Context context){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
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

    private static Intent getLaunchIntent(Context context) {
        String packageName = context.getPackageName();
        PackageManager packageManager = context.getPackageManager();
        return packageManager.getLaunchIntentForPackage(packageName);
    }
}
