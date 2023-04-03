/*
 * Copyright (c) 2022-2023 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

import 'account_box.dart';

/// The [AccountListTile] widget contains details of the [Account].
class AccountListTile extends StatelessWidget {

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;
  final Widget child;

  const AccountListTile({Key key, this.leading, this.title, this.subtitle, this.trailing, this.child}) : super(key: key);

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
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
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
                    style: TextStyle(fontSize: 20),
                  )
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    subtitle,
                    style: TextStyle(fontSize: 17),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  )
                ),
              ],
            )),
            trailing,
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