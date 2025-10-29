/*
 * Copyright (c) 2022-2025 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forgerock_authenticator/exception/exceptions.dart';

import 'package:forgerock_authenticator/forgerock_authenticator.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator/models/mechanism.dart';
import 'package:forgerock_authenticator/models/oath_token_code.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';

/// This provider works as a bridge between the native SDK and the app. It provides data
/// and operations required to manage OTP and Push accounts
class AuthenticatorProvider with ChangeNotifier {
  List<Account> _accountList = <Account>[];
  Map<String, Account> _accountIndex = <String, Account>{};

  void updateAccountIndex() {
    _accountIndex = <String, Account>{};
    for (final Account a in _accountList) {
      final String? accountId = a.id;
      if (accountId != null && accountId.isNotEmpty) {
        _accountIndex[accountId] = a;
      }
    }
  }

  Account? getAccount(String accountId) {
    return _accountIndex[accountId];
  }

  static Future<void> initialize() async {
    try {
      await ForgerockAuthenticator.start();
    } on PlatformException catch (e) {
      debugPrint(e.toString());
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
    try {
      final Mechanism mechanism =
          await ForgerockAuthenticator.createMechanismFromUri(uri);
      await getAllAccounts();
      return mechanism;
    } on PlatformException catch (e) {
      if (e.code == ForgerockAuthenticator.DuplicateMechanismException) {
        final String mechanismId =
            e.details is String && (e.details as String).isNotEmpty
                ? e.details as String
                : 'unknown';
        return Future<Mechanism>.error(
          DuplicateMechanismException(
            mechanismId,
            e.message ?? 'This authentication method is already registered.',
          ),
        );
      }
      if (e.code == ForgerockAuthenticator.CreateMechanismException) {
        return Future<Mechanism>.error(MechanismCreationException(e.message));
      } else if (e.code == ForgerockAuthenticator.PolicyViolationException) {
        final String policyName =
            e.details is String && (e.details as String).isNotEmpty
                ? e.details as String
                : 'unknown';
        return Future<Mechanism>.error(
          PolicyViolationException(
            policyName,
            e.message ??
                'The account cannot be registered on this device. It violates some policy',
          ),
        );
      } else {
        return Future<Mechanism>.error(e);
      }
    }
  }

  Future<bool> removeAccount(String accountId) async {
    final bool success =
        await ForgerockAuthenticator.removeAccount(accountId) ?? false;
    if (success) {
      await getAllAccounts();
    }
    return success;
  }

  Future<OathTokenCode?> getOathTokenCode(String mechanismId) async {
    try {
      return ForgerockAuthenticator.getOathTokenCode(mechanismId);
    } on PlatformException catch (e) {
      if (e.code == ForgerockAuthenticator.AccountLockException) {
        return Future<OathTokenCode>.error(AccountLockException(e.message));
      } else {
        return Future<OathTokenCode>.error(e);
      }
    }
  }

  static Future<bool> performPushAuthentication(
      PushNotification pushNotification, bool accept) async {
    try {
      final bool result =
          await ForgerockAuthenticator.performPushAuthentication(
                pushNotification,
                accept,
              ) ??
              false;
      return result;
    } on PlatformException catch (e) {
      if (e.code == ForgerockAuthenticator.AccountLockException) {
        return Future<bool>.error(AccountLockException(e.message));
      } else if (e.code == ForgerockAuthenticator.HandleNotificationException) {
        return Future<bool>.error(HandleNotificationException(e.message));
      } else {
        return Future<bool>.error(e);
      }
    }
  }

  static Future<bool> performPushAuthenticationWithChallenge(
      PushNotification pushNotification,
      String? challengeResponse,
      bool accept) async {
    try {
      final bool result =
          await ForgerockAuthenticator.performPushAuthenticationWithChallenge(
                pushNotification,
                challengeResponse ?? '',
                accept,
              ) ??
              false;
      return result;
    } on PlatformException catch (e) {
      if (e.code == ForgerockAuthenticator.AccountLockException) {
        return Future<bool>.error(AccountLockException(e.message));
      } else if (e.code == ForgerockAuthenticator.HandleNotificationException) {
        return Future<bool>.error(HandleNotificationException(e.message));
      } else {
        return Future<bool>.error(e);
      }
    }
  }

  static Future<bool> performPushAuthenticationWithBiometric(
      PushNotification pushNotification,
      String title,
      bool allowDeviceCredentials,
      bool accept) async {
    try {
      final bool result =
          await ForgerockAuthenticator.performPushAuthenticationWithBiometric(
                pushNotification,
                title,
                allowDeviceCredentials,
                accept,
              ) ??
              false;
      return result;
    } on PlatformException catch (e) {
      if (e.code == ForgerockAuthenticator.AccountLockException) {
        return Future<bool>.error(AccountLockException(e.message));
      } else if (e.code == ForgerockAuthenticator.HandleNotificationException) {
        return Future<bool>.error(HandleNotificationException(e.message));
      } else {
        return Future<bool>.error(e);
      }
    }
  }
}
