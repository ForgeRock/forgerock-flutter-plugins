/*
 * Copyright (c) 2022-2023 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

package org.forgerock.forgerock_authenticator;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentActivity;

import org.forgerock.android.auth.FRAClientWrapper;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/** ForgerockAuthenticatorPlugin */
public class ForgerockAuthenticatorPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler,
        PluginRegistry.NewIntentListener, ActivityAware {

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private FRAClientWrapper fraClientWrapper;
  private FragmentActivity activity;
  private ActivityPluginBinding activityBinding;
  private FRRequestPermissionListener permissionListener;
  private Context context;
  private BroadcastReceiver changeReceiver;
  private String initialLink;
  private String latestLink;
  private boolean initialIntent = true;

  private static final String CHANNEL_NAME = "forgerock_authenticator";
  private static final String EVENTS_CHANNEL = "forgerock_authenticator/events";

  @SuppressWarnings("unused")
  public ForgerockAuthenticatorPlugin() { }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
    register(flutterPluginBinding.getBinaryMessenger(), flutterPluginBinding.getApplicationContext());
  }

  private void register(BinaryMessenger messenger, Context context) {
    this.context = context;
    this.channel = new MethodChannel(messenger, CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
    this.fraClientWrapper = FRAClientWrapper.init(context);
    this.fraClientWrapper.setChannel(channel);

    final EventChannel eventChannel = new EventChannel(messenger, EVENTS_CHANNEL);
    eventChannel.setStreamHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getInitialLink":
        result.success(this.initialLink);
        break;
      case "getLatestLink":
        result.success(this.latestLink);
        break;
      case "start":
        this.fraClientWrapper.start(result, permissionListener);
        break;
      case "createMechanismFromUri":
        String uri = call.argument("uri");
        this.fraClientWrapper.createMechanismFromUri(uri, result);
        break;
      case "getAllAccounts":
        this.fraClientWrapper.getAllAccounts(result);
        break;
      case "getOathTokenCode": {
        String mechanismId = call.argument("mechanismId");
        this.fraClientWrapper.getOathTokenCode(mechanismId, result);
        break;
      }
      case "updateAccount": {
        String accountJson = call.argument("accountJson");
        this.fraClientWrapper.updateAccount(accountJson, result);
        break;
      }
      case "removeAccount": {
        String accountId = call.argument("accountId");
        this.fraClientWrapper.removeAccount(accountId, result);
        break;
      }
      case "lockAccount": {
        String accountId = call.argument("accountId");
        String policyName = call.argument("policyName");
        this.fraClientWrapper.lockAccount(accountId, policyName, result);
        break;
      }
      case "unlockAccount": {
        String accountId = call.argument("accountId");
        this.fraClientWrapper.unlockAccount(accountId, result);
        break;
      }
      case "removeMechanism": {
        String mechanismUID = call.argument("mechanismUID");
        this.fraClientWrapper.removeMechanism(mechanismUID, result);
        break;
      }
      case "removeAllNotifications": {
        this.fraClientWrapper.removeAllNotifications(result);
        break;
      }
      case "getNotificationsByAccountId": {
        String accountId = call.argument("accountId");
        this.fraClientWrapper.getAllNotificationsByAccountId(accountId, result);
        break;
      }
      case "getAllNotifications":
        this.fraClientWrapper.getAllNotifications(result);
        break;
      case "getNotification": {
        String notificationId = call.argument("notificationId");
        this.fraClientWrapper.getNotification(notificationId, result);
        break;
      }
      case "getAllMechanismsGroupByUID":
        this.fraClientWrapper.getAllMechanismsGroupByUID(result);
        break;
      case "handleMessage": {
        String messageId = call.argument("messageId");
        String message = call.argument("message");
        this.fraClientWrapper.handleMessage(messageId, message, result);
        break;
      }
      case "performPushAuthentication": {
        String notificationId = call.argument("notificationId");
        boolean accept = Boolean.TRUE.equals(call.argument("accept"));
        this.fraClientWrapper.performPushAuthentication(notificationId, accept, result);
        break;
      }
      case "performPushAuthenticationWithChallenge": {
        String notificationId = call.argument("notificationId");
        String challengeResponse = call.argument("challengeResponse");
        boolean accept = Boolean.TRUE.equals(call.argument("accept"));
        this.fraClientWrapper.performPushAuthenticationWithChallenge(notificationId,
                challengeResponse, accept, result);
        break;
      }
      case "performPushAuthenticationWithBiometric": {
        String notificationId = call.argument("notificationId");
        String title = call.argument("title");
        boolean allowDeviceCredentials = Boolean.TRUE.equals(call.argument("allowDeviceCredentials"));
        boolean accept = Boolean.TRUE.equals(call.argument("accept"));
        FragmentActivity fragmentActivity = (FragmentActivity) activity;
        this.fraClientWrapper.performPushAuthenticationWithBiometric(notificationId, title,
                allowDeviceCredentials, accept, fragmentActivity, result);
        break;
      }
      case "setStoredAccount": {
        String accountJson = call.argument("accountJson");
        this.fraClientWrapper.setStoredAccount(accountJson, result);
        break;
      }
      case "setStoredMechanism":
        String mechanismJson = call.argument("mechanismJson");
        this.fraClientWrapper.setStoredMechanism(mechanismJson, result);
        break;
      case "setStoredNotification":
        String notificationJson = call.argument("notificationJson");
        this.fraClientWrapper.setStoredNotification(notificationJson, result);
        break;
      case "getStoredAccount": {
        String accountId = call.argument("accountId");
        this.fraClientWrapper.getStoredAccount(accountId, result);
        break;
      }
      case "getStoredMechanism": {
        String mechanismId = call.argument("mechanismId");
        this.fraClientWrapper.getStoredMechanism(mechanismId, result);
        break;
      }
      case "getStoredMechanismByUUID": {
        String mechanismId = call.argument("mechanismUID");
        this.fraClientWrapper.getStoredMechanismByUUID(mechanismId, result);
        break;
      }
      case "getStoredNotification": {
        String notificationId = call.argument("notificationId");
        this.fraClientWrapper.getStoredNotification(notificationId, result);
        break;
      }
      case "deleteStoredAccount": {
        String accountId = call.argument("accountId");
        this.fraClientWrapper.deleteStoredAccount(accountId, result);
        break;
      }
      case "removeAllData":
        this.fraClientWrapper.removeAllData();
        break;
      case "getBackup": {
        String id = call.argument("id");
        this.fraClientWrapper.getBackup(id, result);
        break;
      }
      case "setBackup": {
        String id = call.argument("id");
        String data = call.argument("data");
        this.fraClientWrapper.setBackup(id, data, result);
        break;
      }
      case "disableScreenshot": {
        if(isActivityAvailable(result)) {
          this.activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
          result.success(true);
        }
        break;
      }
      case "enableScreenshot": {
        if(isActivityAvailable(result)) {
          this.activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_SECURE);
          result.success(true);
        }
        break;
      }
      default:
        result.notImplemented();
        break;
    }
  }

  private boolean isActivityAvailable(Result result) {
    if (this.activity == null) {
      result.error(
              "WINDOW_MANAGER_EXCEPTION",
              "Ignored window flag state change, current activity is null",
              null);
      return false;
    } else {
      return true;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    this.channel.setMethodCallHandler(null);
    this.channel = null;
    this.fraClientWrapper = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    this.activityBinding = activityPluginBinding;
    this.activity = (FragmentActivity) activityPluginBinding.getActivity();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      this.permissionListener = new FRRequestPermissionListener(this.activity);
      activityPluginBinding.addRequestPermissionsResultListener(this.permissionListener);
    }

    activityPluginBinding.addOnNewIntentListener(this);

    this.handleIntent(this.context, activityPluginBinding.getActivity().getIntent());
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    this.activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {
    onAttachedToActivity(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivity() {
    tearDown();
  }

  @Override
  public boolean onNewIntent(Intent intent) {
    this.handleIntent(this.context, intent);
    return false;
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink eventSink) {
    this.changeReceiver = createChangeReceiver(eventSink);
  }

  @Override
  public void onCancel(Object arguments) {
    this.changeReceiver = null;
  }

  @NonNull
  private BroadcastReceiver createChangeReceiver(final EventChannel.EventSink events) {
    return new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
         Log.v("fra_sdk", String.format("received action: %s", intent.getAction()));

        String dataString = intent.getDataString();

        if (dataString == null) {
          events.error("UNAVAILABLE", "Link unavailable", null);
        } else {
          events.success(dataString);
        }
      }
    };
  }

  private void handleIntent(Context context, Intent intent) {
    String action = intent.getAction();
    String dataString = intent.getDataString();

    if (Intent.ACTION_VIEW.equals(action)) {
      if (initialIntent) {
        this.initialLink = dataString;
        this.initialIntent = false;
      }
      this.latestLink = dataString;
      if (this.changeReceiver != null) this.changeReceiver.onReceive(context, intent);
    }
  }

  private void tearDown() {
    this.activity = null;
    this.activityBinding.removeRequestPermissionsResultListener(permissionListener);
    this.activityBinding = null;
    this.permissionListener = null;
  }
}
