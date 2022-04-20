/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

class ForgeRockAppBar extends StatelessWidget implements PreferredSizeWidget {

  const ForgeRockAppBar({Key key, this.title, this.actions}) : super(key: key);

  final List<Widget> actions;
  final String title;

  @override
  Widget build(BuildContext context) {
    return (title != null)
        ? withTitle(context)
        : noTitle(context);
  }

  Widget withTitle(BuildContext context) {
    return AppBar(
      elevation: 0,
      foregroundColor: Colors.black,
      backgroundColor: const Color(0xffF6F5F8),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700),),
      centerTitle: true,
      actions: actions,
    );
  }

  Widget noTitle(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      foregroundColor: Colors.black,
      backgroundColor: const Color(0xffF6F5F8),
      centerTitle: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(58);

}
