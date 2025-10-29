/*
 * Copyright (c) 202-2025 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/widgets/account_card.dart';
import 'package:forgerock_authenticator_example/widgets/account_list_empty.dart';
import 'package:forgerock_authenticator_example/widgets/app_bar.dart';

/// This is the Accounts screen, which allows removing an account from the app.
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthenticatorAppBar(),
      body: Consumer<AuthenticatorProvider>(
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
                edit: true,
              );
            },
          );
        },
      ),
    );
  }
}
