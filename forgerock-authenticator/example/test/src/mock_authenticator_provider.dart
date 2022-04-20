/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator/models/oath_mechanism.dart';
import 'package:forgerock_authenticator/models/oath_token_code.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:mockito/mockito.dart';

import 'sample_data.dart';

class MockAuthenticatorProvider extends Mock implements AuthenticatorProvider  {

  @override
  Account getAccount(String id) {
    Account result;
    for (int i = 0; i < accounts.length; i++) {
      if(accounts[i].id == id) {
        result = accounts[i];
        break;
      }
    }
    return result;
  }

  @override
  Future<void> updateAccount(String id, String issuer, String accountName) async {
    final Account account = getAccount(id);
    if(account != null) {
      if(accountName != null && accountName.isNotEmpty) {
        account.displayAccountName = accountName;
      }
      if(issuer != null && issuer.isNotEmpty) {
        account.displayIssuer = issuer;
      }
      await getAllAccounts();
    }
  }

  @override
  Future<void> removeAccount(String accountId) async {
    final List<String> accountListOrderIndex = getAccountOrderIndex();
    int index = -1;
    for (int i = 0; i < accounts.length; i++) {
      if(accounts[i].id == accountId) {
        index = i;
        break;
      }
    }

    if (index != -1) {
      accounts.removeAt(index);
      accountListOrderIndex.remove(accountId);
      notifyListeners();
      await getAllAccounts();
    }
  }

}

MockAuthenticatorProvider createMockAuthenticatorProvider() {
  final MockAuthenticatorProvider authenticator = MockAuthenticatorProvider();
  final Account account1 = Account.fromJson(SampleData.account1Json as Map<String, dynamic>);
  final Account account2 = Account.fromJson(SampleData.account2Json as Map<String, dynamic>);
  final Account account3 = Account.fromJson(SampleData.account3Json as Map<String, dynamic>);

  final List<Account> mockAccountList = <Account>[
    account1, account2, account3
  ];

  final List<String> mockAccountListOrderIndex = <String>[
    account1.id, account2.id, account3.id
  ];

  when(authenticator.accounts).thenAnswer((_) => mockAccountList);
  when(authenticator.getAllAccounts()).thenAnswer((_) => Future<List<Account>>.value(mockAccountList));
  when(authenticator.getAccountOrderIndex()).thenAnswer((_) => mockAccountListOrderIndex);
  when(authenticator.getOathTokenCode(any)).thenAnswer((_) async => OathTokenCode('123456', 1000, 0, TokenType.HOTP));
  when(authenticator.getIndexNotifier()).thenAnswer((_) => ValueNotifier<List<String>>(mockAccountListOrderIndex));

  return authenticator;
}

MockAuthenticatorProvider createMockAuthenticatorProviderEmpty() {
  final MockAuthenticatorProvider authenticator = MockAuthenticatorProvider();
  final List<Account> mockAccountList = List<Account>.empty();
  final List<String> mockAccountListOrderIndex = List<String>.empty();

  when(authenticator.accounts).thenAnswer((_) => mockAccountList);
  when(authenticator.getAllAccounts()).thenAnswer((_) => Future<List<Account>>.value(mockAccountList));
  when(authenticator.getAccountOrderIndex()).thenAnswer((_) => mockAccountListOrderIndex);
  when(authenticator.getIndexNotifier()).thenAnswer((_) => ValueNotifier<List<String>>(mockAccountListOrderIndex));

  return authenticator;
}