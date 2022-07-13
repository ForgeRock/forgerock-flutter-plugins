/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';


class DefaultButton extends StatelessWidget {

  final VoidCallback action;
  final String text;
  final Color color;

  const DefaultButton({Key key, this.action, this.text, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        key: key,
        style: ElevatedButton.styleFrom(
          primary: color,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0)),
          minimumSize: const Size(150, 50),
        ),
        onPressed: action,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
        )
    );
  }

}