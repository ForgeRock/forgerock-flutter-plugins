/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator_example/widgets/account_card_layout.dart';
import 'package:forgerock_authenticator_example/widgets/account_logo.dart';
import 'package:forgerock_authenticator_example/widgets/rounded_expansion_tile.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';

import 'account_detail_switcher.dart';
import 'expandable_icon.dart';

class AccountTileExpandable extends StatelessWidget {

  const AccountTileExpandable({Key key, this.account}) : super(key: key);

  final Account account;

  @override
  Widget build(BuildContext context) {
    return AccountCardLayout(
      child: RoundedExpansionTile(
        expanded: false,
        leading: Container(
            alignment: Alignment.center,
            width: 52,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: AccountLogo(account: account)
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: TextScale(child: Text(
          account.getIssuer(),
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        )),
        subtitle: TextScale(child: Text(
          account.getAccountName(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: const TextStyle(fontSize: 16),
        )),
        // trailing: const Icon(Icons.keyboard_arrow_down),
        trailing: const ExpandableIcon(
          child: Icon(Icons.keyboard_arrow_down),
        ),
        rotateTrailing: true,
        children: <Widget>[
          AccountDetailSwitcher(account: account),
        ],
      ),
    );
  }

}