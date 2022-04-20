/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:forgerock_authenticator/exception/exceptions.dart';
import 'package:forgerock_authenticator/forgerock_authenticator.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator/models/mechanism.dart';
import 'package:forgerock_authenticator/models/oath_token_code.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';
import 'package:forgerock_authenticator_example/helpers/account_index_helper.dart';
import 'package:forgerock_authenticator_example/helpers/diagnostic_logger.dart';

// This provider works as a bridge between the native SDK and the app. It provides all data
// and operations required to manage OTP and Push accounts
class AuthenticatorProvider with ChangeNotifier {

  AuthenticatorProvider() {
    init();
  }

  List<Account> _accountList = <Account>[];
  List<PushNotification> _notificationList = <PushNotification>[];
  final AccountIndexHelper _accountIndexHelper = AccountIndexHelper();

  Future<void> init() async {
    _accountList = await refreshAccounts();
  }

  List<Account> get accounts {
    return <Account>[..._accountList];
  }

  List<PushNotification> get notifications {
    return <PushNotification>[..._notificationList];
  }

  ValueNotifier<List<String>> getIndexNotifier() {
    return _accountIndexHelper.indexNotifier;
  }

  List<String> getAccountOrderIndex() {
    return _accountIndexHelper.orderIndex;
  }

  void setAccountOrderIndex(List<String> list) {
    _accountIndexHelper.orderIndex = list;
    notifyListeners();
  }

  bool isNewAccountIndex() {
    return _accountIndexHelper.initAccountOrderIndex;
  }

  Account getAccount(String accountId) {
    return _accountIndexHelper.getAccountById(accountId);
  }

  static Future<void> initialize() async {
    try {
      await ForgerockAuthenticator.start();
    } on PlatformException catch(e) {
      print(e);
    }
  }

  Future<List<Account>> getAllAccounts() async {
    return _accountList;
  }

  Future<List<Account>> refreshAccounts() async {
    _accountList = await ForgerockAuthenticator.getAllAccounts();
    _accountIndexHelper.updateAccountIndex(_accountList);
    notifyListeners();
    return _accountList;
  }

  Mechanism getMechanismByUID(String uid) {
    for(final Account account in _accountList) {
      for(final Mechanism mechanism in account.mechanismList) {
        if(mechanism.mechanismUID == uid) {
          return mechanism;
        }
      }
    }
    return null;
  }

  Account getAccountByMechanismUID(String uid) {
    for(final Account account in _accountList) {
      for(final Mechanism mechanism in account.mechanismList) {
        if(mechanism.mechanismUID == uid) {
          return account;
        }
      }
    }
    return null;
  }

  Future<PushNotification> getNotificationByMessageId(String messageId) async {
    print('Looking for : $messageId');
    final List<PushNotification> notificationList = await getAllNotifications();
    print('notifications #: ${notificationList.length}');
    for(final PushNotification pushNotification in notificationList) {
      print('Comparing with: ${pushNotification.messageId}');
      if(pushNotification.messageId == messageId) {
        print('found!!!');
        return pushNotification;
      }
    }
    return null;
  }

  Future<Mechanism> addAccount(String uri) async {
    try {
      final Mechanism mechanism = await ForgerockAuthenticator.createMechanismFromUri(uri);
      if (mechanism != null) {
        refreshAccounts();
      }
      return mechanism;
    } on PlatformException catch(e) {
      if( e.code == ForgerockAuthenticator.DuplicateMechanismException) {
        return Future<Mechanism>.error(DuplicateMechanismException());
      } if( e.code == ForgerockAuthenticator.CreateMechanismException) {
        return Future<Mechanism>.error(MechanismCreationException(e.message));
      } else {
        return Future<Mechanism>.error(e);
      }
    }
  }

  Future<void> updateAccount(String id, String issuer, String accountName) async {
    DiagnosticLogger.fine('Updating account $id with issuer=$issuer and accountName=$accountName');
    final Account account = getAccount(id);
    if(account != null) {
      if(accountName != null && accountName.isNotEmpty) {
        account.displayAccountName = accountName;
      }
      if(issuer != null && issuer.isNotEmpty) {
        account.displayIssuer = issuer;
      }
      final String json = account.toString();
      final bool success = await ForgerockAuthenticator.updateAccount(json);
      if(success) {
        refreshAccounts();
      }
    }
  }

  Future<void> removeAccount(String accountId) async {
    DiagnosticLogger.fine('Deleting account with ID: $accountId');
    final bool success = await ForgerockAuthenticator.removeAccount(accountId);
    if(success) {
      _accountIndexHelper.removeAccountById(accountId);
      refreshAccounts();
    }
  }

  Future<void> removeMechanism(String mechanismUID) async {
    DiagnosticLogger.fine('Deleting OATH mechanism with ID: $mechanismUID');
    final bool success = await ForgerockAuthenticator.removeMechanism(mechanismUID);
    if(success) {
      refreshAccounts();
    }
  }

  Future<OathTokenCode> getOathTokenCode(String mechanismId) async {
    final OathTokenCode oathTokenCode = await ForgerockAuthenticator.getOathTokenCode(mechanismId);
    return oathTokenCode;
  }

  Future<List<PushNotification>> getAllNotifications() async {
    if(_notificationList.isEmpty) {
      _notificationList = await refreshNotifications();
    }
    return _notificationList;
  }

  Future<List<PushNotification>> refreshNotifications() async {
    _notificationList = await ForgerockAuthenticator.getAllNotifications();
    notifyListeners();
    return _notificationList;
  }

  PushNotification getLatestNotification({Account account}) {
    if(notifications.isEmpty) {
      return null;
    } else {
      if(account != null) {
        final Mechanism mechanism = account.getPushMechanism();
        if(mechanism != null) {
          for(final PushNotification p in notifications) {
            if(p.mechanismUID == mechanism.mechanismUID) {
              return p;
            }
          }
        }
      }
      return null;
    }
  }

  int getPendingNotificationsCount({Account account}) {
    int count = 0;
    if(notifications.isEmpty) {
      return 0;
    } else {
      if(account != null) {
        final Mechanism mechanism = account.getPushMechanism();
        if(mechanism != null) {
          for(final PushNotification notification in notifications) {
            if(notification.mechanismUID == mechanism.mechanismUID) {
              if(notification.pending && !notification.isExpired()) {
                count += 1;
              } else {
                return count;
              }
            }
          }
        }
      }
      return count;
    }
  }

  static Future<PushNotification> handleMessageWithPayload(Map<String, dynamic> userInfo) async {
    try {
      return await ForgerockAuthenticator.handleMessageWithPayload(userInfo);
    } on Exception catch(e) {
      return Future<PushNotification>.error(e);
    }
  }

  Future<bool> performPushAuthentication(PushNotification pushNotification, bool accept) async {
    try {
      final bool result = await ForgerockAuthenticator.performPushAuthentication(pushNotification, accept);
      if(result) {
        refreshNotifications();
      }
      return result;
    } on PlatformException catch(e) {
      if( e.code == ForgerockAuthenticator.HandleNotificationException) {
        return Future<bool>.error(HandleNotificationException(e.message));
      } else {
        return Future<bool>.error(e);
      }
    }
  }

  Future<void> clearPreviousData() async {
    ForgerockAuthenticator.removeAllData();
    await refreshAccounts();
  }

  static Future<bool> performPushAuthenticationOnBackground(PushNotification pushNotification, bool accept) async {
    try {
      return ForgerockAuthenticator.performPushAuthentication(pushNotification, accept);
    } on PlatformException catch(e) {
      print(e);
      return false;
    }
  }

  static Future<bool> disableScreenshot() async {
    return ForgerockAuthenticator.disableScreenshot();
  }

  static Future<bool> enableScreenshot() async {
    return ForgerockAuthenticator.enableScreenshot();
  }

  static Future<void> removeAllData() async {
    return ForgerockAuthenticator.removeAllData();
  }

  static Future<bool> hasAlreadyLaunched() async {
    return ForgerockAuthenticator.hasAlreadyLaunched();
  }

}