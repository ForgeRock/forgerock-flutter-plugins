/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

class AccountCardLayout extends StatelessWidget {

  const AccountCardLayout({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey[300], width: 1.2),
          borderRadius: BorderRadius.circular(8)),
      child: child,
    );
  }

}