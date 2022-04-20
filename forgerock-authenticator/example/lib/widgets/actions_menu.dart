/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

import 'package:forgerock_authenticator_example/screens/accounts_screen.dart';

/// The [ActionsMenu] widget contains the actions available on the [AppBar].
class ActionsMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (selectedValue) {
        switch(selectedValue) {
          case 'edit': {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountsScreen()),
            );
          }
          break;
        }
      },
      itemBuilder: (BuildContext ctx) =>
      [
        PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Accounts'),
            ),
            value: 'edit'
        ),
      ]
    );
  }

}
