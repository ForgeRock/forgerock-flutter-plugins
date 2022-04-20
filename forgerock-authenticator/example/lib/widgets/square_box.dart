/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

class SquareBox extends StatelessWidget {

  const SquareBox({Key key, this.child, this.padding}) : super(key: key);

  final Widget child;
  final bool padding;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: padding ? const EdgeInsets.all(5) : EdgeInsets.zero,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6), bottom: Radius.circular(6)),
        ),
        height: 50.0,
        width: 50.0,
        child: Stack(
            children: <Widget>[
              Positioned(
                  child: Align(
                      alignment: FractionalOffset.center,
                      child: child
                  )
              )
            ])
    );
  }


}