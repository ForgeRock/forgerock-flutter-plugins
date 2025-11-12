/*
 * Copyright (c) 2022-2025 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/widgets/account_list_empty.dart';

import 'account_card.dart';

/// The [AccountList] widget lists all accounts registered with the SDK.
class AccountList extends StatelessWidget {
  const AccountList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticatorProvider>(
      builder: (BuildContext context,
          AuthenticatorProvider authenticatorProvider, Widget? child) {
        final accounts = authenticatorProvider.accounts;
        if (accounts.isEmpty) {
          return const AccountEmptyList();
        }
        return ListView.builder(
          itemCount: accounts.length,
          itemBuilder: (BuildContext context, int index) {
            final account = accounts[index];
            return AccountCard(
              key: ValueKey(account.id ?? index),
              account: account,
              edit: false,
            );
          },
        );
      },
    );
  }
}
