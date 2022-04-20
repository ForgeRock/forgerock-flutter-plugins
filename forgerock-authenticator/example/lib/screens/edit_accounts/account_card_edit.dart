/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator_example/screens/edit_accounts/account_delete.dart';
import 'package:forgerock_authenticator_example/screens/edit_accounts/account_edit_form.dart';
import 'package:forgerock_authenticator_example/widgets/account_card_layout.dart';

import '../../widgets/account_header.dart';

class AccountCardEdit extends StatelessWidget {

  const AccountCardEdit({Key key, this.account}) : super(key: key);

  final Account account;

  @override
  Widget build(BuildContext context) {
    if(account != null) {
      return AccountCardLayout(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            accountTile(),
            editButton(context),
            deleteButton(context),
            reorderButton(),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget accountTile() {
    return Expanded(
      flex: 2,
      child: AccountHeader(account: account),
    );
  }

  Widget reorderButton() {
    return Align(
      alignment: Alignment.center,
      child:
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: IconButton(
          icon: const Icon(
            Icons.drag_indicator,
            color: Colors.black,
            size: 26.0,
          ),
          onPressed: () { },
        )
      )
    );
  }

  Widget editButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child:
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: IconButton(
          icon: const Icon(
            Icons.edit,
            color: Colors.black,
            size: 26.0,
          ),
          onPressed: () {
            editAccountAction(context);
          },
        )
      )
    );
  }

  Widget deleteButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child:
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.black,
            size: 26.0,
          ),
          onPressed: () {
            deleteAccountAction(context);
          },
        )
      )
    );
  }

  void editAccountAction(BuildContext context) {
    showModalBottomSheet<Widget>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                color: const Color(0xFF737373),
                child: Container(
                  height: 340,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: Colors.white,
                  ),
                  child: AccountEdit(account: account),
                ),
              ),
          );
        });
  }

  void deleteAccountAction(BuildContext context) {
    showDialog<Widget>(context: context, builder: (BuildContext context) {
      return AccountDelete(account: account);
    });
  }

}
