/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

/// This widget represents the bar on the top of the application. It also contains
/// an [ActionMenu].
class AuthenticatorAppBar extends StatelessWidget implements PreferredSizeWidget{
  final List<Widget> actions;

  AuthenticatorAppBar({Key key, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xff006ac8),
      title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.lock,
              size: 24,
              color: Colors.white,
            ),
            Container(width: 5),
            Text('Authenticator')
          ]),
      centerTitle: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(58);

}