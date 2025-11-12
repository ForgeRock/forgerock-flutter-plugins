/*
 * Copyright (c) 2022-2025 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

import 'package:forgerock_authenticator_example/screens/accounts_screen.dart';

/// The [ActionsMenu] widget contains the actions available on the [AppBar].
class ActionsMenu extends StatelessWidget {
  const ActionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String selectedValue) {
        switch (selectedValue) {
          case 'edit':
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const AccountsScreen(),
              ),
            );
            break;
        }
      },
      itemBuilder: (BuildContext ctx) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Accounts'),
          ),
        ),
      ],
    );
  }
}
