/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

class TextScale extends StatelessWidget {

  const TextScale({Key key, this.child, this.maxFactor}) : super(key: key);

  final Widget child;
  final num maxFactor;

  @override
  Widget build(BuildContext context) {
    num max = maxFactor ?? 1.5;
    max = MediaQuery.of(context).size.height > 800 ? max : 1.1;

    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final num constrainedTextScaleFactor = mediaQueryData.textScaleFactor.clamp(1.0, max);

    return MediaQuery(
      data: mediaQueryData.copyWith(
        textScaleFactor: constrainedTextScaleFactor as double,
      ),
      child: child,
    );
  }

}