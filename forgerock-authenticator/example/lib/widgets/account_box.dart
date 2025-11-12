/*
 * Copyright (c) 2022-2025 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

/// This widget decorates the [AccountCard] with a BoxShadow.
class AccountBox extends StatelessWidget {
  const AccountBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 30,
              offset: const Offset(0, 8))
        ],
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1.0),
      ),
      child: child,
    );
  }

}
