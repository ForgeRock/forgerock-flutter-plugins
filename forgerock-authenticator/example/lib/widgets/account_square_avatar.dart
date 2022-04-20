/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator_example/util/strings_util.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';

class AccountSquareAvatar extends StatelessWidget {

  const AccountSquareAvatar({Key key, this.issuer}) : super(key: key);

  final String issuer;

  @override
  Widget build(BuildContext context) {
    final String hexColor = stringToColour(issuer);
    final Color color = colorFromHex(hexColor);
    return Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6), bottom: Radius.circular(6)),
            ),
          ),
          Positioned(
              child: Align(
                alignment: FractionalOffset.center,
                child: SizedBox(
                    child: TextScale(
                      maxFactor: 1.0,
                      child: Text(
                        getInitials(issuer, limitTo: 1),
                        style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    )
                ),
              )
          )
        ]);
  }

}