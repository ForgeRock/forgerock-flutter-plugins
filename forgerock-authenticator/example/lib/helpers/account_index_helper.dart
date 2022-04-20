/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator/models/account.dart';

import '/providers/settings_provider.dart';

/// This Helper class keeps an Index to easily retrieve accounts and change the order.
class AccountIndexHelper {

  // Index of account
  List<String> _accountOrderIndex = <String>[];
  // Account map by accountId
  Map<String, Account> _accountMapIndex;
  // Notifier for account index changes
  ValueNotifier<List<String>> indexNotifier;
  // Indicates the account index is being created for the first time
  bool initAccountOrderIndex;

  /// Update the account map and index
  Future<void> updateAccountIndex(List<Account> accountList) async {
    _accountMapIndex = <String, Account>{};

    // setup account order index
    initAccountOrderIndex = false;
    _accountOrderIndex = await SettingsProvider.getAccountsOrder();
    if(_accountOrderIndex.isEmpty) {
      initAccountOrderIndex = true;
    }

    // populate account Map
    for(final Account a in accountList) {
      _accountMapIndex[a.id] = a;

      if(initAccountOrderIndex) {
        _accountOrderIndex.add(a.id);
      } else {
        if(!_accountOrderIndex.contains(a.id)) {
          _accountOrderIndex.add(a.id);
        }
      }
    }

    // make sure the order index does not contain any orphan account
    if(_accountOrderIndex.length > _accountMapIndex.length) {
      _removeForOrphanAccountsFromIndex();
    }

    // set notifier for account order index
    if(indexNotifier == null) {
      indexNotifier = ValueNotifier<List<String>>(_accountOrderIndex);
    } else {
      indexNotifier.value = _accountOrderIndex;
    }

    // save account order index, if it was first initialized
    if(initAccountOrderIndex) {
      SettingsProvider.saveAccountsOrder(_accountOrderIndex);
    }
  }

  /// Get account order index
  List<String> get orderIndex {
    return <String>[..._accountOrderIndex];
  }

  /// Set account order index
  set orderIndex(List<String> list) {
    _accountOrderIndex = list;
    _updateOrderIndex();
  }

  /// Save account order index on SharedPreferences
  Future<void> _updateOrderIndex() async {
    await SettingsProvider.saveAccountsOrder(_accountOrderIndex);
  }

  /// Get account from map using accountId
  Account getAccountById(String accountId) {
    return _accountMapIndex[accountId];
  }

  /// Remove account from order index using accountId
  void removeAccountById(String accountId) {
    _accountOrderIndex.remove(accountId);
    _accountMapIndex.remove(accountId);
    indexNotifier.value = _accountOrderIndex;
    _updateOrderIndex();
  }

  void addAccount(String accountId) {
    _accountOrderIndex.add(accountId);
    indexNotifier.value = _accountOrderIndex;
    _updateOrderIndex();
  }

  void _removeForOrphanAccountsFromIndex() {
    final List<String> toRemove = <String>[];
    for(final String accountId in _accountOrderIndex) {
      if (!_accountMapIndex.keys.contains(accountId)) {
        toRemove.add(accountId);
      }
    }
    if(toRemove.isNotEmpty) {
      _accountOrderIndex.removeWhere( (String e) => toRemove.contains(e));
      SettingsProvider.saveAccountsOrder(_accountOrderIndex);
    }
  }

}
