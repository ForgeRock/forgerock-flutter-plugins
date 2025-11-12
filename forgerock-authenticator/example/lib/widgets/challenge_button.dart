/*
 * Copyright (c) 2022-2025 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

class ChallengeButton extends StatelessWidget {
  const ChallengeButton({
    super.key,
    required this.action,
    required this.text,
  });

  final VoidCallback action;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: ElevatedButton(
        key: key,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.grey,
          shape: const CircleBorder(),
          minimumSize: const Size(65, 65),
        ),
        onPressed: action,
        child: Text(
          text,
          style: const TextStyle(fontSize: 20),
        )
      )
    );
  }

}
