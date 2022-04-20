/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {

  const GradientBackground({Key key, this.child, this.begin, this.end}) : super(key: key);

  final Widget child;
  final Color begin;
  final Color end;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter, // 10% of the width, so there are ten blinds.
          colors: <Color>[
            begin,
            end
          ], // red to yellow
          tileMode: TileMode.repeated, // repeats the gradient over the canvas
        ),
      ),
      child: child,
    );
  }

}