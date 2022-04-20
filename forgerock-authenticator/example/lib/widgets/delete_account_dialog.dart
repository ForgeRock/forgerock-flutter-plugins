/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/authenticator_provider.dart';

/// Displays an modal to confirm the [Account] deletion.
void deleteAccount(BuildContext context, String id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Remove Account"),
        content: Text("Are you sure you want to remove this account? If you "
            "choose to continue, keep in mind that you may not be able to access"
            " the system associated with this account."),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () { Navigator.of(context).pop(); },
          ),
          TextButton(
            child: Text("Continue"),
            onPressed: () {
              Provider.of<AuthenticatorProvider>(context, listen: false)
                  .removeAccount(id);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
