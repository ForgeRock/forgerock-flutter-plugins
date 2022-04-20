/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:forgerock_authenticator/forgerock_authenticator.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator/models/mechanism.dart';
import 'package:forgerock_authenticator/models/oath_token_code.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';

/// This provider works as a bridge between the native SDK and the app. It provides data
/// and operations required to manage OTP and Push accounts
class AuthenticatorProvider with ChangeNotifier {
  List<Account> _accountList = <Account>[];
  Map<String, Account> _accountIndex;

  void updateAccountIndex() {
    _accountIndex = <String, Account>{};
    for(final Account a in _accountList) {
      _accountIndex[a.id] = a;
    }
  }

  Account getAccount(String accountId) {
    return _accountIndex[accountId];
  }

  static Future<void> initialize() async {
    try {
      await ForgerockAuthenticator.start();
    } on PlatformException catch(e) {
      print(e);
    }
  }

  List<Account> get accounts {
    return [..._accountList];
  }

  Future<List<Account>> getAllAccounts() async {
    _accountList = await ForgerockAuthenticator.getAllAccounts();
    updateAccountIndex();
    notifyListeners();
    return _accountList;
  }

  Future<Mechanism> addAccount(String uri) async {
    final Mechanism mechanism = await ForgerockAuthenticator.createMechanismFromUri(uri);
    if (mechanism != null) {
      getAllAccounts();
    }
    return mechanism;
  }

  Future<bool> removeAccount(String accountId) async {
    final bool success = await ForgerockAuthenticator.removeAccount(accountId);
    if(success) {
      getAllAccounts();
    }
    return success;
  }

  Future<OathTokenCode> getOathTokenCode(String mechanismId) async {
    return ForgerockAuthenticator.getOathTokenCode(mechanismId);
  }

  static Future<bool> performPushAuthentication(PushNotification pushNotification, bool accept) async {
    return ForgerockAuthenticator.performPushAuthentication(pushNotification, accept);
  }

}