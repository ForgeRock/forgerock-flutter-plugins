/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator_example/helpers/diagnostic_logger.dart';

import 'account_square_avatar.dart';

class NetworkLogo extends StatelessWidget {

  const NetworkLogo({Key key, this.imageURL, this.issuer}) : super(key: key);

  final String imageURL;
  final String issuer;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageURL,
      fit: BoxFit.contain,
      width: 42,
      height: 42,
      alignment: Alignment.center,
      errorBuilder: (BuildContext context, Object error, StackTrace stackTrace) {
        DiagnosticLogger.fine(
            'Error downloading networking image using URL: $imageURL',
            error);
        return AccountSquareAvatar(issuer: issuer);
      },
    );
  }

}