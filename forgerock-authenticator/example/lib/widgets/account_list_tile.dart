/*
 * Copyright (c) 2022-2025 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

import 'account_box.dart';

/// The [AccountListTile] widget contains details of the [Account].
class AccountListTile extends StatelessWidget {
  const AccountListTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.child,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AccountBox(
      child: Column(children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  width: 80,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: leading
                ),
              ],
            ),
            Expanded(
                child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 20),
                  )
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    subtitle,
                    style: const TextStyle(fontSize: 17),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  )
                ),
              ],
            )),
            trailing ?? const SizedBox.shrink(),
          ]
        ),
        Row(
          children: [
            Column(
              children: [
                Container(
                  width: 80,
                ),
            ]),
            Column(
                children: [
                  child,
            ])
        ]),
      ])
    );
  }

}
