/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator_example/util/strings_util.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';

class AccountCircleAvatar extends StatelessWidget {

  const AccountCircleAvatar({Key key, this.issuer}) : super(key: key);
  
  final String issuer;

  @override
  Widget build(BuildContext context) {
    final String hexColor = stringToColour(issuer);
    final Color color = colorFromHex(hexColor);
    return CircleAvatar(
      backgroundColor: color,
      child: TextScale(
        maxFactor: 1.0,
        child: Text(
          getInitials(issuer, limitTo: 1),
          style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
    );
  }

}