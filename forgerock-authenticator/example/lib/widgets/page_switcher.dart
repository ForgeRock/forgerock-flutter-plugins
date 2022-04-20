/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

class PageSwitcher extends StatelessWidget {

  const PageSwitcher({Key key, this.index, this.currentIndex}) : super(key: key);

  final int index;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(right: 4),
        height: 6,
        width: 6,
        // width: _currentIndex == index ? 15 : 5,
        decoration: currentIndex == index
            ? BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(3))
            : BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(3))
    );
  }

}