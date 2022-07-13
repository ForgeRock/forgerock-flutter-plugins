/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';


class ChallengeButton extends StatelessWidget {

  final VoidCallback action;
  final String text;

  const ChallengeButton({Key key, this.action, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: ElevatedButton(
        key: key,
        style: ElevatedButton.styleFrom(
          primary: Colors.grey,
          onPrimary: Colors.white,
          shape: CircleBorder(),
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