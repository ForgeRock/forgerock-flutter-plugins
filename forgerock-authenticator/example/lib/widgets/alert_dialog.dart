/*
 * Copyright (c) 2022-2025 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

/// Displays a modal dialog with the supplied title and message.
Future<void> alert(BuildContext context, String title, String message) =>
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                message,
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
