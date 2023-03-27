/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

package org.forgerock.android.auth;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

/**
 * Data Access Object which implements StorageClient interface and uses SecureSharedPreferences from
 * forgerock-core SDK to store and load Accounts, Mechanisms and Notifications.
 */
class FRAStorageClient implements StorageClient {

    //Alias to store keys
    private static final String FORGEROCK_SHARED_PREFERENCES_KEYS = "com.forgerock.authenticator.KEYS";

    //Settings to store the data
    private static final String FORGEROCK_SHARED_PREFERENCES_DATA_ACCOUNT = "com.forgerock.authenticator.DATA.ACCOUNT";
    private static final String FORGEROCK_SHARED_PREFERENCES_DATA_MECHANISM = "com.forgerock.authenticator.DATA.MECHANISM";
    private static final String FORGEROCK_SHARED_PREFERENCES_DATA_NOTIFICATIONS = "com.forgerock.authenticator.DATA.NOTIFICATIONS";
    private static final String FORGEROCK_SHARED_PREFERENCES_DATA_BACKUP = "com.forgerock.authenticator.DATA.BACKUP";

    //The SharedPreferences to store the data
    private final SharedPreferences accountData;
    private final SharedPreferences mechanismData;
    private final SharedPreferences notificationData;
    private final SharedPreferences backupData;

    private final HashMap<String, Account> accountMap;
    private final HashMap<String, Mechanism> mechanismMap;
    private final HashMap<String, PushNotification> notificationMap;

    private static final String TAG = DefaultStorageClient.class.getSimpleName();
    private static final int NOTIFICATIONS_MAX_SIZE = 20;

    /**
     * Constructor.
     *
     * @param context application context.
     */
    public FRAStorageClient(Context context) {
        this.accountData = new SecuredSharedPreferences(context,
                FORGEROCK_SHARED_PREFERENCES_DATA_ACCOUNT, FORGEROCK_SHARED_PREFERENCES_KEYS);
        this.mechanismData = new SecuredSharedPreferences(context,
                FORGEROCK_SHARED_PREFERENCES_DATA_MECHANISM, FORGEROCK_SHARED_PREFERENCES_KEYS);
        this.notificationData = new SecuredSharedPreferences(context,
                FORGEROCK_SHARED_PREFERENCES_DATA_NOTIFICATIONS, FORGEROCK_SHARED_PREFERENCES_KEYS);
        this.backupData = new SecuredSharedPreferences(context,
                FORGEROCK_SHARED_PREFERENCES_DATA_BACKUP, FORGEROCK_SHARED_PREFERENCES_KEYS);

        this.accountMap = new HashMap<>();
        this.mechanismMap = new HashMap<>();
        this.notificationMap = new HashMap<>();
    }

    @Override
    public Account getAccount(String accountId) {
        if(this.accountMap.containsKey(accountId)) {
            return this.accountMap.get(accountId);
        } else {
            String json = accountData.getString(accountId, "");
            return Account.deserialize(json);
        }
    }

    @Override
    public List<Account> getAllAccounts() {
        List<Account> accountList;

        if(this.accountMap.isEmpty()) {
            accountList = new ArrayList<>();
            Map<String,?> keys = accountData.getAll();
            for(Map.Entry<String,?> entry : keys.entrySet()){
                if(entry.getValue() != null) {
                    Logger.debug(TAG, "Account map values: ",entry.getKey() + ": " + entry.getValue().toString());
                    Account account = Account.deserialize(entry.getValue().toString());
                    if(account != null) {
                        accountList.add(account);
                        this.accountMap.put(account.getId(), account);
                    }
                }
            }
        } else {
            accountList = new ArrayList<>(this.accountMap.values());
        }

        return accountList;
    }

    @Override
    public boolean removeAccount(Account account) {
        boolean success = accountData.edit()
                .remove(account.getId())
                .commit();

        if(success) {
            this.accountMap.remove(account.getId());
        }

        return success;
    }

    @Override
    public boolean setAccount(Account account) {
        String accountJson = account.serialize();

        boolean success = accountData.edit()
                .putString(account.getId(), accountJson)
                .commit();

        if(success) {
            this.accountMap.put(account.getId(), account);
        }

        return success;
    }

    /**
     * Get all mechanisms stored in the system.
     *
     * @return The complete list of mechanisms.
     */
    public List<Mechanism> getAllMechanisms() {
        List<Mechanism> mechanismList;

        if(this.mechanismMap.isEmpty()) {
            mechanismList = new ArrayList<>();
            Map<String,?> keys = mechanismData.getAll();
            for(Map.Entry<String,?> entry : keys.entrySet()){
                if(entry.getValue() != null) {
                    Logger.debug(TAG, "Mechanism map values: ",entry.getKey() + ": " + entry.getValue().toString());
                    String jsonData = entry.getValue().toString();

                    Mechanism mechanism = Mechanism.deserialize(jsonData);
                    if(mechanism != null) {
                        mechanismList.add(mechanism);
                        this.mechanismMap.put(mechanism.getId(), mechanism);
                    }
                }
            }
        } else {
            mechanismList = new ArrayList<>(this.mechanismMap.values());
        }

        return mechanismList;
    }

    @Override
    public List<Mechanism> getMechanismsForAccount(Account account) {
        List<Mechanism> mechanismList = new ArrayList<>();

        List<Mechanism> allMechanisms = this.getAllMechanisms();
        for(Mechanism mechanism : allMechanisms){
            if(mechanism.getIssuer().equals(account.getIssuer()) &&
                    mechanism.getAccountName().equals(account.getAccountName())){
                mechanismList.add(mechanism);
            }
        }

        return mechanismList;
    }

    private String getMechanismId(String mechanismId) {
        mechanismId = mechanismId.replace('#', '-');
        if (mechanismId.contains("-hotp")) {
            return mechanismId.replaceAll("-hotp", "-otpauth");
        } else if (mechanismId.contains("-totp")) {
            return mechanismId.replaceAll("-totp", "-otpauth");
        } else {
            return mechanismId.replaceAll("-push", "-pushauth");
        }
    }

    public Mechanism getMechanism(String mechanismId) {
        String id = getMechanismId(mechanismId);
        if(this.mechanismMap.containsKey(id)) {
            return this.mechanismMap.get(id);
        } else {
            String json = mechanismData.getString(id, "");
            return Mechanism.deserialize(json);
        }
    }

    @Override
    public Mechanism getMechanismByUUID(String mechanismUID) {
        Mechanism mechanism = null;

        List<Mechanism> allMechanisms;
        if(this.mechanismMap.isEmpty()) {
            allMechanisms = this.getAllMechanisms();
        } else {
            allMechanisms = new ArrayList<>(this.mechanismMap.values());
        }

        for(Mechanism mechanismEntry : allMechanisms){
            if (mechanismEntry.getMechanismUID().equals(mechanismUID)) {
                mechanism = mechanismEntry;
                break;
            }
        }

        return mechanism;
    }

    @Override
    public boolean removeMechanism(Mechanism mechanism) {
        boolean success = mechanismData.edit()
                .remove(mechanism.getId())
                .commit();

        if(success) {
            this.mechanismMap.remove(mechanism.getId());
        }

        return success;
    }

    @Override
    public boolean setMechanism(Mechanism mechanism) {
        String mechanismJson = mechanism.serialize();

        boolean success = mechanismData.edit()
                .putString(mechanism.getId(), mechanismJson)
                .commit();

        if(success) {
            this.mechanismMap.put(mechanism.getId(), mechanism);
        }

        return success;
    }

    /**
     * Get all notifications stored in the system.
     *
     * @return The complete list of notifications.
     */
    @Override
    public List<PushNotification> getAllNotifications() {
        List<PushNotification> pushNotificationList;

        if(this.notificationMap.isEmpty()) {
            pushNotificationList = new ArrayList<>();
            Map<String,?> keys = notificationData.getAll();
            for(Map.Entry<String,?> entry : keys.entrySet()){
                if(entry.getValue() != null) {
                    Logger.debug(TAG, "PushNotification map values: ",
                            entry.getKey() + ": " + entry.getValue().toString());
                    PushNotification pushNotification = PushNotification.deserialize(entry.getValue().toString());
                    if(pushNotification != null) {
                        pushNotificationList.add(pushNotification);
                        this.notificationMap.put(pushNotification.getId(), pushNotification);
                    }
                }
            }
        } else {
            pushNotificationList = new ArrayList<>(this.notificationMap.values());
        }

        Collections.sort(pushNotificationList);
        return this.removeOldNotificationEntries(pushNotificationList);
    }

    private List<PushNotification> removeOldNotificationEntries(List<PushNotification> pushNotificationList) {
        Logger.debug(TAG, "Checking old PushNotification entries to remove...");
        int removedEntries = 0;
        while (pushNotificationList.size() > NOTIFICATIONS_MAX_SIZE) {
            int lastElement = pushNotificationList.size() - 1;
            this.removeNotification(pushNotificationList.get(lastElement));
            pushNotificationList.remove(lastElement);
            removedEntries++;
        }
        Logger.debug(TAG, removedEntries + " PushNotification entries removed.");
        return pushNotificationList;
    }

    @Override
    public List<PushNotification> getAllNotificationsForMechanism(Mechanism mechanism) {
        List<PushNotification> pushNotificationList = new ArrayList<>();

        List<PushNotification> allPushNotifications = this.getAllNotifications();
        for(PushNotification pushNotification : allPushNotifications){
            if(pushNotification.getMechanismUID().equals(mechanism.getMechanismUID())){
                pushNotification.setPushMechanism(mechanism);
                pushNotificationList.add(pushNotification);
            }
        }

        return pushNotificationList;
    }

    @Override
    public boolean removeNotification(PushNotification pushNotification) {
        boolean success = notificationData.edit()
                .remove(pushNotification.getId())
                .commit();

        if(success) {
            this.notificationMap.remove(pushNotification.getId());
        }

        return success;
    }

    /**
     * Remove all the stored {@link PushNotification}
     */
    public void removeAllNotifications() {
        notificationData.edit()
                .clear()
                .commit();
        notificationMap.clear();
    }

    /**
     * Get the PushNotification object with its id
     * @param notificationId The PushNotification unique ID
     * @return The PushNotification object.
     */
    public PushNotification getNotification(String notificationId) {
        if(this.notificationMap.containsKey(notificationId)) {
            return this.notificationMap.get(notificationId);
        } else {
            String json = notificationData.getString(notificationId, null);
            return PushNotification.deserialize(json);
        }
    }

    @Override
    public boolean setNotification(@NonNull PushNotification pushNotification) {
        String notificationJson = pushNotification.serialize();

        boolean success = notificationData.edit()
                .putString(pushNotification.getId(), notificationJson)
                .commit();

        if(success) {
            if(this.notificationMap.isEmpty()) {
                this.getAllNotifications();
            }

            this.notificationMap.put(pushNotification.getId(), pushNotification);
        }

        return success;
    }

    @Override
    public boolean isEmpty() {
        return accountData.getAll().isEmpty() &&
                mechanismData.getAll().isEmpty() &&
                notificationData.getAll().isEmpty();
    }

    /**
     * Get the backup data with its id
     * @param id The backup unique ID
     * @return The backup data.
     */
    public String getBackup(String id) {
        return backupData.getString(id, "");
    }

    /**
     * Add or update the backup to the storage system.
     * @param id The identifier of the data.
     * @param jsonData The data as JSON string to store.
     * @return boolean as result of the operation
     */
    public boolean setBackup(String id, String jsonData) {
        return backupData.edit()
                .putString(id, jsonData)
                .commit();
    }

    /**
     * Remove all the stored {@link Account}, {@link Mechanism} and {@link PushNotification}
     */
    @SuppressLint("ApplySharedPref")
    public void removeAll() {
        accountData.edit()
                .clear()
                .commit();
        mechanismData.edit()
                .clear()
                .commit();
        notificationData.edit()
                .clear()
                .commit();
        backupData.edit()
                .clear()
                .commit();
        accountMap.clear();
        mechanismMap.clear();
        notificationMap.clear();
    }

}

