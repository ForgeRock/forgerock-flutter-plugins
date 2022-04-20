/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator_example/screens/edit_accounts/edit_accounts_screen.dart';

import 'account_tile.dart';
import 'account_tile_expandable.dart';

class AccountCard extends StatelessWidget {

  const AccountCard({Key key, this.account, this.expanded}) : super(key: key);

  final Account account;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Navigator.push(
          context,
          PageRouteBuilder<EditAccountsScreen>(
            pageBuilder: (BuildContext context, Animation<double> animation1, Animation<double> animation2) => const EditAccountsScreen(),
            transitionDuration: Duration.zero,
          ),
        );
      },
      child: expanded ? AccountTile(account: account) : AccountTileExpandable(account: account),
    );
  }

}
