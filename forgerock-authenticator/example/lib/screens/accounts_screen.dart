/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/widgets/account_card.dart';
import 'package:forgerock_authenticator_example/widgets/app_bar.dart';
import 'package:forgerock_authenticator_example/widgets/account_list_empty.dart';

/// This is the Accounts screen, which allows remove an account from the app.
class AccountsScreen extends StatefulWidget {

  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AuthenticatorAppBar(),
        body: Consumer<AuthenticatorProvider>(
          builder: (context, authenticatorProvider, child) {
            if (authenticatorProvider.accounts.isNotEmpty) {
              return ListView(
                children: List.generate(authenticatorProvider.accounts.length, (index) {
                  return AccountCard(
                      ValueKey(authenticatorProvider.accounts[index].id),
                      authenticatorProvider.accounts[index],
                      true
                  );
                }),
              );
            } else {
              return AccountEmptyList();
            }
          },
        )
    );
  }

}