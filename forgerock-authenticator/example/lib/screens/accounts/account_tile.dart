/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator_example/widgets/account_card_layout.dart';
import 'package:forgerock_authenticator_example/widgets/account_header.dart';

import 'account_detail_switcher.dart';

class AccountTile extends StatelessWidget {

  const AccountTile({Key key, this.account}) : super(key: key);

  final Account account;

  @override
  Widget build(BuildContext context) {
    return AccountCardLayout(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AccountHeader(account: account),
            AccountDetailSwitcher(account: account),
          ]
      ),
    );
  }

}