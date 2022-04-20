/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/screens/accounts/account_list.dart';
import 'package:provider/provider.dart';

class AccountsScreen extends StatelessWidget {

  const AccountsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Account>>(
        future: Provider.of<AuthenticatorProvider>(context, listen: false).getAllAccounts(),
        builder: (BuildContext context, AsyncSnapshot<List<Account>> dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.error != null) {
              return Center(
                child: Text('${AppLocalizations.of(context).homeScreenError} \n${dataSnapshot.error.toString()}'),
              );
            } else {
              return const AccountList();
            }
          }
        }
    );
  }

}