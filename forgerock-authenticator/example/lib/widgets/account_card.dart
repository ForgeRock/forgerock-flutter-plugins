/*
 * Copyright (c) 2022-2023 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

import 'package:forgerock_authenticator/models/account.dart';

import 'account_detail.dart';
import 'account_logo.dart';
import 'account_list_tile.dart';
import 'delete_account_dialog.dart';

/// The [AccountCard] widget reprentes an [Account] registered with the SDK. This
/// sample does not cover an Account with both OATH and PUSH mechanisms.
class AccountCard extends StatelessWidget {
  final Key key;
  final Account account;
  final bool edit;

  AccountCard(this.key, this.account, this.edit);

  @override
  Widget build(BuildContext context) {
    return AccountListTile(
      leading: AccountLogo(
                  imageURL: account.imageURL,
                  textFallback: account.issuer,
                ),
      title: account.issuer,
      subtitle: account.accountName,
      trailing: edit ? _deleteButton(context) : _emptyContainer(),
      child: edit ? _emptyContainer() : _accountDetail(),
    );
  }

  Widget _deleteButton(BuildContext context) {
    return Expanded(child: Align(
      alignment: Alignment.bottomRight,
      child:
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.grey,
            size: 28.0,
          ),
          onPressed: () {
            deleteAccount(context, account.id);
          },
        )
      )
    ));
  }

  Widget _emptyContainer() {
    return Container(height: 0, width: 0,);
  }

  Widget _accountDetail() {
    if (account.lock) {
      return SizedBox(
        width: 230,
        child: Text('Your account is locked due the policy: ' + account.lockingPolicy,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.fromLTRB(5, 2, 0, 0),
        child: AccountDetail(account),
      );
    }
  }

}

