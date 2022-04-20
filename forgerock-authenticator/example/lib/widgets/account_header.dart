/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';

import 'account_logo.dart';

class AccountHeader extends StatelessWidget {

  const AccountHeader({Key key, this.account}) : super(key: key);

  final Account account;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
          alignment: Alignment.center,
          width: 50,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: AccountLogo(account: account)
      ),
      title: TextScale(child: Text(
        account.getIssuer(),
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: const TextStyle(fontSize: 18),
      )),
      subtitle: TextScale(child: Text(
        account.getAccountName(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: const TextStyle(fontSize: 16),
      )),
    );
  }

}