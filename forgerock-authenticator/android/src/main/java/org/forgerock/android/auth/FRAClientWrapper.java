/*
 * Copyright (c) 2022-2023 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

package org.forgerock.android.auth;

import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentActivity;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.messaging.FirebaseMessaging;

import org.forgerock.android.auth.exception.AccountLockException;
import org.forgerock.android.auth.exception.AuthenticatorException;
import org.forgerock.android.auth.exception.DuplicateMechanismException;
import org.forgerock.android.auth.exception.InvalidNotificationException;
import org.forgerock.android.auth.exception.InvalidPolicyException;
import org.forgerock.android.auth.exception.MechanismPolicyViolationException;
import org.forgerock.android.auth.exception.OathMechanismException;
import org.forgerock.android.auth.policy.FRAPolicy;
import org.forgerock.forgerock_authenticator.FRRequestPermissionListener;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

public class FRAClientWrapper {

    private static FRAClientWrapper INSTANCE = null;

    private static final String TAG = FRAClientWrapper.class.getSimpleName();

    private final Context context;
    private final FRAStorageClient storageClient;
    private FRAClient fraClient;
    private FRAPolicyEvaluator policyEvaluator;
    private String fcmToken;
    private MethodChannel channel;

    private FRAClientWrapper(Context context) {
        this.context = context;
        this.storageClient = new FRAStorageClient(context);
        try {
            this.policyEvaluator = FRAPolicyEvaluator.builder().build();
        } catch (InvalidPolicyException e) {
            Log.e(TAG, "Error building Policy evaluator.", e);
        }
    }

    public static FRAClientWrapper getInstance() {
        if (INSTANCE == null) {
            throw new IllegalStateException("FRAClientWrapper is not initialized. " +
                    "Please make sure to call FRAClientWrapper#init first.");
        }
        return INSTANCE;
    }

    public static FRAClientWrapper init(@NonNull Context context) {
        synchronized (FRAClientWrapper.class) {
            if (INSTANCE == null) {
                INSTANCE = new FRAClientWrapper(context);
            }
            return INSTANCE;
        }
    }

    protected static FRAClientWrapper getInstanceInBackground(@NonNull Context context) {
        FRAClientWrapper clientWrapper = init(context);
        clientWrapper.startInBackground();
        return clientWrapper;
    }

    public void setChannel(MethodChannel channel) {
        this.channel = channel;
    }

    private void startInBackground() {
        try {
            if (fraClient == null) {
                Log.d(TAG, "Starting SDK in background.");
                fraClient = FRAClient.builder()
                        .withContext(context)
                        .withStorage(storageClient)
                        .withPolicyEvaluator(policyEvaluator)
                        .start();
            }
        } catch (AuthenticatorException e) {
            Log.e(TAG, "Error initializing SDK in background.", e);
        }
    }

    public void start(final Result flutterResult, final FRRequestPermissionListener permissionListener) {
        try {
            // Initialise SDK passing application Context and custom StorageClient
            fraClient = FRAClient.builder()
                    .withContext(context)
                    .withStorage(storageClient)
                    .withPolicyEvaluator(policyEvaluator)
                    .start();

            // Retrieve the FCM token
            FirebaseMessaging.getInstance().getToken()
                    .addOnCompleteListener(new OnCompleteListener<String>() {
                        @Override
                        public void onComplete(@NonNull Task<String> task) {
                            if (!task.isSuccessful()) {
                                if(task.getException() != null) {
                                    Log.e(TAG, "FirebaseMessaging.getInstance failed",
                                            task.getException());
                                    flutterResult.error("PUSH_REGISTRATION_EXCEPTION",
                                            "FirebaseMessaging.getInstance failed",
                                            task.getException().getLocalizedMessage());
                                }
                                return;
                            }

                            // Get new Instance ID token
                            fcmToken = task.getResult();
                            if(channel != null) {
                                channel.invokeMethod("onToken", fcmToken);
                            }

                            // Register the token with the SDK to enable Push mechanisms
                            try {
                                fraClient.registerForRemoteNotifications(fcmToken);

                                // Request notification permission for Android 13 and above
                                if (Build.VERSION.SDK_INT >= 33) {
                                    permissionListener.requestPermissions(new FRRequestPermissionListener.RequestPermission() {
                                        @Override
                                        public void onRequestPermissionSuccess() {
                                            Log.d(TAG, "Notification permission granted.");
                                        }

                                        @Override
                                        public void onRequestPermissionFailure() {
                                            Log.d(TAG, "Notification permission denied.");
                                        }
                                    });
                                }

                                flutterResult.success(true);
                            } catch (AuthenticatorException e) {
                                Log.e(TAG, "PUSH_REGISTRATION_EXCEPTION", e);
                                flutterResult.error("PUSH_REGISTRATION_EXCEPTION",
                                        e.getLocalizedMessage(),
                                        "Device token: " + fcmToken);
                            }
                        }
                    });
        } catch (AuthenticatorException e) {
            flutterResult.error("AUTHENTICATOR_EXCEPTION", e.getLocalizedMessage(), null);
        }
    }

    public void createMechanismFromUri(String uri, final Result flutterResult) {
        fraClient.createMechanismFromUri(uri, new FRAListener<Mechanism>() {
            @Override
            public void onSuccess(Mechanism result) {
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        flutterResult.success(result.toJson());
                    }
                });
            }

            @Override
            public void onException(Exception e) {
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        if (e instanceof DuplicateMechanismException)  {
                            flutterResult.error("DUPLICATE_MECHANISM_EXCEPTION", e.getLocalizedMessage(),
                                    ((DuplicateMechanismException) e).getCausingMechanism().getId());
                        } else if (e instanceof MechanismPolicyViolationException) {
                            flutterResult.error("POLICY_VIOLATION_EXCEPTION", e.getLocalizedMessage(),
                                    ((MechanismPolicyViolationException) e).getCausingPolicy().getName());
                        } else {
                            flutterResult.error("CREATE_MECHANISM_EXCEPTION", e.getLocalizedMessage(),
                                    null);
                        }
                    }
                });
            }
        });
    }

    public void getAllAccounts(final Result flutterResult) {
        new FRARetrieveAccountsTask(fraClient, flutterResult).run();
    }

    public void updateAccount(String accountJson, Result flutterResult) {
        Account account = Account.deserialize(accountJson);
        try {
            if (account != null) {
                flutterResult.success(fraClient.updateAccount(account));
            } else {
                flutterResult.success(false);
            }
        } catch (AccountLockException e) {
            flutterResult.error("ACCOUNT_LOCK_EXCEPTION", e.getLocalizedMessage(), null);
        }
    }

    public void removeAccount(String accountId, Result flutterResult) {
        Account account = storageClient.getAccount(accountId);
        if (account != null) {
            flutterResult.success(fraClient.removeAccount(account));
        } else {
            flutterResult.success(false);
        }
    }

    public void lockAccount(String accountId, String policyName, Result flutterResult) {
        Account account = storageClient.getAccount(accountId);
        FRAPolicy fraPolicy = getPolicyByName(policyName);
        try {
            if (account != null && fraPolicy != null) {
                flutterResult.success(fraClient.lockAccount(account, fraPolicy));
            } else {
                flutterResult.error("ACCOUNT_LOCK_EXCEPTION", "Error locking the account: Invalid parameters.", null);
            }
        } catch (AccountLockException e) {
            flutterResult.error("ACCOUNT_LOCK_EXCEPTION", e.getLocalizedMessage(), null);
        }
    }

    public void unlockAccount(String accountId, Result flutterResult) {
        Account account = storageClient.getAccount(accountId);
        try {
            if (account != null) {
                flutterResult.success(fraClient.unlockAccount(account));
            } else {
                flutterResult.error("ACCOUNT_LOCK_EXCEPTION", "Error unlocking the account: Invalid parameters.", null);
            }
        } catch (AccountLockException e) {
            flutterResult.error("ACCOUNT_LOCK_EXCEPTION", e.getLocalizedMessage(), null);
        }
    }

    public void removeMechanism(String mechanismUID, Result flutterResult) {
        Mechanism mechanism = storageClient.getMechanismByUUID(mechanismUID);
        if (mechanism != null) {
            flutterResult.success(fraClient.removeMechanism(mechanism));
        } else {
            flutterResult.success(false);
        }
    }

    public void removeAllNotifications(Result flutterResult) {
        storageClient.removeAllNotifications();
        flutterResult.success(true);
    }

    public void getOathTokenCode(String mechanismId, Result flutterResult) {
        OathMechanism oathMechanism = (OathMechanism)storageClient.getMechanism(mechanismId);

        if(oathMechanism != null) {
            try {
                flutterResult.success(oathMechanism.getOathTokenCode().toJson());
            } catch (OathMechanismException e) {
                flutterResult.error("OATH_MECHANISM_EXCEPTION", e.getLocalizedMessage(), oathMechanism.toJson());
            } catch (AccountLockException e) {
                flutterResult.error("ACCOUNT_LOCK_EXCEPTION", e.getLocalizedMessage(), null);
            }
        }
    }

    public void getAllNotificationsByAccountId(String accountId, Result flutterResult) {
        Account account = fraClient.getAccount(accountId);
        if (account != null) {
            List<Mechanism> mechanismList = account.getMechanisms();
            Mechanism mechanism = null;
            for(Mechanism m : mechanismList) {
                if(m.getType().equals(Mechanism.PUSH)) {
                    mechanism = m;
                }
            }

            if (mechanism != null) {
                List<PushNotification> notificationList = fraClient.getAllNotifications(mechanism);
                List<String> jsonList  = new ArrayList<>();
                for(PushNotification p : notificationList) {
                    jsonList.add(p.toJson());
                }
                flutterResult.success(jsonList);
            } else {
                flutterResult.success(Collections.EMPTY_LIST);
            }
        }
    }

    public void getAllNotifications(Result flutterResult) {
        List<PushNotification> notificationList = fraClient.getAllNotifications();
        List<String> jsonList  = new ArrayList<>();
        for(PushNotification p : notificationList) {
            jsonList.add(p.toJson());
        }
        flutterResult.success(jsonList);
    }

    public void getNotification(String notificationId, Result flutterResult) {
        PushNotification notification = fraClient.getNotification(notificationId);
        if (notification != null) {
            flutterResult.success(notification.serialize());
        } else {
            flutterResult.success(null);
        }
    }

    public PushNotification getNotification(String notificationId) {
        return fraClient.getNotification(notificationId);
    }

    private PushNotification getNotificationByMessageId(String messageId) {
        List<PushNotification> allPushNotifications = fraClient.getAllNotifications();
        for(PushNotification pushNotification : allPushNotifications){
            if(pushNotification.getMessageId().equals(messageId)){
                return pushNotification;
            }
        }
        return null;
    }

    public Mechanism getMechanism(@NonNull PushNotification notification) {
        return fraClient.getMechanism(notification);
    }

    public void getAllMechanismsGroupByUID(Result flutterResult) {
        Map<String,String> mechanismList = new HashMap<>();

        List<Mechanism> allMechanisms = storageClient.getAllMechanisms();
        for(Mechanism mechanism : allMechanisms){
            String jsonData = mechanism.toJson();
            mechanismList.put(mechanism.getMechanismUID(), jsonData);
        }

        flutterResult.success(mechanismList);
    }

    public void handleMessage(String messageId, String message, Result flutterResult) {
        try {
            PushNotification pushNotification = getNotificationByMessageId(messageId);
            if (pushNotification != null) {
                flutterResult.success(pushNotification.toJson());
            } else {
                pushNotification = fraClient.handleMessage(messageId, message);
                if(pushNotification != null) {
                    flutterResult.success(pushNotification.toJson());
                } else {
                    flutterResult.success(null);
                }
            }
        } catch (InvalidNotificationException e) {
            flutterResult.error("INVALID_NOTIFICATION_EXCEPTION",
                    e.getLocalizedMessage(),
                    "messageId: " + messageId + "message: " + message);
        }
    }

    protected PushNotification handleMessageInBackground(String messageId, String message) {
        try {
            PushNotification pushNotification = fraClient.handleMessage(messageId, message);
            if(channel != null && pushNotification != null) {
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    public void run() {
                        channel.invokeMethod("onMessage", pushNotification.toJson());
                    }
                });
            }
            return pushNotification;
        } catch (InvalidNotificationException e) {
            return null;
        }
    }

    public void performPushAuthentication(String notificationId, boolean accept,
                                          Result flutterResult) {
        PushNotification pushNotification = fraClient.getNotification(notificationId);
        if (accept) {
            pushNotification.accept(pushAuthenticationListener(pushNotification, flutterResult));
        } else {
            denyMessage(pushNotification, flutterResult);
        }
    }

    public void performPushAuthenticationWithChallenge(String notificationId,
                                                       String challengeResponse,
                                                       boolean accept,
                                                       Result flutterResult) {
        PushNotification pushNotification = fraClient.getNotification(notificationId);
        if (accept) {
            pushNotification.accept(challengeResponse,
                    pushAuthenticationListener(pushNotification, flutterResult));
        } else {
            denyMessage(pushNotification, flutterResult);
        }
    }

    public void performPushAuthenticationWithBiometric(String notificationId,
                                                       String title,
                                                       boolean allowDeviceCredentials,
                                                       boolean accept,
                                                       FragmentActivity activity,
                                                       Result flutterResult) {
        PushNotification pushNotification = fraClient.getNotification(notificationId);
        if (accept) {
            pushNotification.accept(title, null, allowDeviceCredentials, activity,
                    pushAuthenticationListener(pushNotification, flutterResult));
        } else {
            denyMessage(pushNotification, flutterResult);
        }
    }

    private void denyMessage(PushNotification pushNotification, Result flutterResult) {
        pushNotification.deny(pushAuthenticationListener(pushNotification, flutterResult));
    }

    private FRAListener<Void> pushAuthenticationListener(PushNotification pushNotification,
                                                         Result flutterResult) {
        return new FRAListener<Void>() {
            @Override
            public void onSuccess(Void result) {
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        flutterResult.success(true);
                    }
                });
            }

            @Override
            public void onException(Exception e) {
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        if (e instanceof AccountLockException) {
                            flutterResult.error("ACCOUNT_LOCK_EXCEPTION",
                                    e.getLocalizedMessage(), pushNotification.toJson());
                        } else {
                            flutterResult.error("HANDLE_NOTIFICATION_EXCEPTION",
                                    e.getLocalizedMessage(), pushNotification.toJson());
                        }
                    }
                });
            }
        };
    }

    private FRAPolicy getPolicyByName(String policyName) {
        for (FRAPolicy policy : policyEvaluator.getPolicies()) {
            if (policy.getName().equals(policyName)) {
                return policy;
            }
        }
        return null;
    }

    //
    // Methods used for Datastore upgrade
    //

    public void getStoredAccount(String accountId, Result flutterResult) {
        Account account = storageClient.getAccount(accountId);
        if (account != null) {
            flutterResult.success(account.serialize());
        } else {
            flutterResult.success(null);
        }
    }

    public void setStoredAccount(String accountJson, Result flutterResult) {
        Account account = Account.deserialize(accountJson);
        if (account != null) {
            flutterResult.success(storageClient.setAccount(account));
        } else {
            flutterResult.success(false);
        }
    }

    public void getStoredMechanism(String mechanismId, Result flutterResult) {
        Mechanism mechanism = storageClient.getMechanism(mechanismId);
        if (mechanism != null) {
            flutterResult.success(mechanism.serialize());
        } else {
            flutterResult.success(null);
        }
    }

    public void getStoredMechanismByUUID(String mechanismUID, Result flutterResult) {
        Mechanism mechanism = storageClient.getMechanismByUUID(mechanismUID);
        if (mechanism != null) {
            flutterResult.success(mechanism.serialize());
        } else {
            flutterResult.success(null);
        }
    }

    public void setStoredMechanism(String mechanismJson, Result flutterResult) {
        Mechanism mechanism = Mechanism.deserialize(mechanismJson);
        if (mechanism != null) {
            flutterResult.success(storageClient.setMechanism(mechanism));
        } else {
            flutterResult.success(false);
        }
    }

    public void getStoredNotification(String notificationId, Result flutterResult) {
        PushNotification notification = storageClient.getNotification(notificationId);
        if (notification != null) {
            flutterResult.success(notification.serialize());
        } else {
            flutterResult.success(null);
        }
    }

    public void setStoredNotification(String notificationJson, Result flutterResult) {
        PushNotification notification = PushNotification.deserialize(notificationJson);
        if (notification != null) {
            flutterResult.success(storageClient.setNotification(notification));
        } else {
            flutterResult.success(false);
        }
    }

    public void getBackup(String id, Result flutterResult) {
        String jsonData = storageClient.getBackup(id);
        if (jsonData != null) {
            flutterResult.success(jsonData);
        } else {
            flutterResult.success(null);
        }
    }

    public void setBackup(String id, String jsonData, Result flutterResult) {
        if (jsonData != null) {
            flutterResult.success(storageClient.setBackup(id, jsonData));
        } else {
            flutterResult.success(false);
        }
    }

    public void deleteStoredAccount(String accountId, Result flutterResult) {
        Account account = storageClient.getAccount(accountId);
        if (account != null) {
            flutterResult.success(storageClient.removeAccount(account));
        }
    }

    public void removeAllData() {
        storageClient.removeAll();
    }

}
