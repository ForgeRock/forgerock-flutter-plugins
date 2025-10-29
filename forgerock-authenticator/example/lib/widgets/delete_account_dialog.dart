/*
 * Copyright (c) 2022-2025 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/authenticator_provider.dart';

/// Displays a modal to confirm the [Account] deletion.
Future<void> deleteAccount(BuildContext context, String? id) async {
  if (id == null || id.isEmpty) {
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Remove Account'),
        content: const Text(
          'Are you sure you want to remove this account? If you choose to continue, '
          'keep in mind that you may not be able to access the system associated with this account.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text('Continue'),
            onPressed: () async {
              await Provider.of<AuthenticatorProvider>(dialogContext,
                      listen: false)
                  .removeAccount(id);
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}
