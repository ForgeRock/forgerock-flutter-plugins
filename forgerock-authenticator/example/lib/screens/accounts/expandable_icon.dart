/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

class ExpandableIcon extends StatelessWidget {

  const ExpandableIcon({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6), bottom: Radius.circular(6)),
        ),
        height: 27.0,
        width: 27.0,
        child: Stack(
            children: <Widget>[
              Positioned(
                  child: Align(
                      alignment: FractionalOffset.center,
                      child: child
                  ))
            ])
    );
  }

}