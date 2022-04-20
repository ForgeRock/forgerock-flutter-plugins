/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator_example/widgets/square_box.dart';

import 'account_square_avatar.dart';
import 'network_logo.dart';

class AccountLogo extends StatelessWidget {

  const AccountLogo({Key key, this.account}) : super(key: key);

  final Account account;

  @override
  Widget build(BuildContext context) {
    if((account.imageURL == null || account.imageURL.trim().isEmpty)
        && account.issuer.toLowerCase().contains('forgerock')) {
      return SquareBox(
        child: Image.asset(
          'assets/images/fr-logo-color-no-text.png',
          key: const Key('fr-logo-color-no-text'),
          fit: BoxFit.fill,
          alignment: Alignment.center,
        ),
        padding: true);
    } else if(account.imageURL == null) {
      return SquareBox(
          child: AccountSquareAvatar(issuer: account.issuer),
          padding: false
      );
    } else {
      return SquareBox(
          child: NetworkLogo(imageURL: account.imageURL, issuer: account.issuer),
          padding: false
      );
    }
  }

}