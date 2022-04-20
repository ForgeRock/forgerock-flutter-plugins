/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:provider/provider.dart';

import '/providers/authenticator_provider.dart';
import '../../widgets/empty_list.dart';
import 'account_card.dart';

class AccountList extends StatelessWidget {

  const AccountList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthenticatorProvider, SettingsProvider>(
      builder: (BuildContext context, AuthenticatorProvider authenticatorProvider, SettingsProvider settingsProvider, Widget child) {
        if (authenticatorProvider.accounts.isNotEmpty) {
          final List<String> accountOrder = authenticatorProvider.getAccountOrderIndex();
          final bool expanded = settingsProvider.visibility;
          return ListView.builder(
            cacheExtent: 9999,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: authenticatorProvider.getAccountOrderIndex().length,
            itemBuilder: (BuildContext context, int index) {
              final Account account = authenticatorProvider.getAccount(accountOrder[index]);
              return account != null
                  ? AccountCard(key: ValueKey<String>(account.id), account: account, expanded: expanded)
                  : Container();
            },
          );
        } else {
          return EmptyList(
            image: 'assets/images/fr-icon-no-accounts.png',
            header: AppLocalizations.of(context).noAccountListHeader,
            description: AppLocalizations.of(context).noAccountListDescription,
          );
        }
      }
    );
  }

}
