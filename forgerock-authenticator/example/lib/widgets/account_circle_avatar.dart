/*
 * Copyright (c) 2022-2025 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

/// This widget creates a [CircleAvatar] to represent the [Account].
class AccountCircleAvatar extends StatelessWidget {
  const AccountCircleAvatar({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final String fallback =
        text.trim().isNotEmpty ? text.trim().substring(0, 1).toUpperCase() : '?';
    return CircleAvatar(
      backgroundColor: Colors.grey,
      child: Text(
        fallback,
        style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

}
