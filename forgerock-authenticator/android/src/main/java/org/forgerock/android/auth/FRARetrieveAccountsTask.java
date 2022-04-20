/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

package org.forgerock.android.auth;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.MethodChannel;

class FRARetrieveAccountsTask implements Runnable {
    private static final String TAG = FRARetrieveAccountsTask.class.getSimpleName();

    private final FRAClient fraClient;
    private final MethodChannel.Result result;

    public FRARetrieveAccountsTask(FRAClient fraClient, MethodChannel.Result result) {
        this.fraClient = fraClient;
        this.result = result;
    }

    @Override
    public void run() {
        Log.d(TAG, "Start fetching accounts...");
        List<String> accounts = new ArrayList<>();;
        try {
            for (Account a : fraClient.getAllAccounts()) {
                List<String> mechanismList = new ArrayList<>();
                for (Mechanism m : a.getMechanisms()) {
                    mechanismList.add(m.toJson());
                }
                JSONObject account = new JSONObject(a.toJson());
                account.put("mechanismList", mechanismList);
                String accountString = account.toString();
                accounts.add(accountString);
            }
            this.sendSuccess(accounts);
        } catch (Exception e) {
            this.sendError(e);
        }
    }

    public void sendError(final Exception exception) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                result.error("ACCOUNT_PARSING_EXCEPTION", exception.getLocalizedMessage(), "");
            }
        });
    }

    public void sendSuccess(final List<String> accounts) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Log.d(TAG, "Finished fetching accounts");
                result.success(accounts);
            }
        });
    }
}
