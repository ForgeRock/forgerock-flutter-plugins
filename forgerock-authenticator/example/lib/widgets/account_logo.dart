/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

import 'account_circle_avatar.dart';

/// The [AccountLogo] widget displays the logo associated with an [Account]. If
/// this is not available it creates a [AccountCircleAvatar].
class AccountLogo extends StatelessWidget {

  final String imageURL;
  final String textFallback;

  const AccountLogo({Key key, this.imageURL, this.textFallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(imageURL == null || imageURL.trim().isEmpty) {
      return AccountCircleAvatar(text: textFallback);
    } else {
      return Image.network(
        imageURL,
        fit: BoxFit.fill,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) {
          return AccountCircleAvatar(text: textFallback);
        },
      );
    }
  }

}