/*
 * Copyright (c) 2022-2025 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

import 'account_circle_avatar.dart';

/// The [AccountLogo] widget displays the logo associated with an [Account]. If
/// this is not available it creates a [AccountCircleAvatar].
class AccountLogo extends StatelessWidget {
  const AccountLogo({super.key, this.imageURL, required this.textFallback});

  final String? imageURL;
  final String textFallback;

  @override
  Widget build(BuildContext context) {
    final String trimmed = imageURL?.trim() ?? '';
    if (trimmed.isEmpty) {
      return AccountCircleAvatar(text: textFallback);
    } else {
      return Image.network(
        trimmed,
        fit: BoxFit.fill,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) {
          return AccountCircleAvatar(text: textFallback);
        },
      );
    }
  }

}
