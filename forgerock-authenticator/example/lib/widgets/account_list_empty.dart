/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

/// This widget is used when the account list is empty.
class AccountEmptyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Icon(
                Icons.account_circle,
                color: Colors.grey[300],
                size: 200,
            ),
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'No accounts!',
                    key: const Key('header'),
                    style: TextStyle(
                      fontSize: 46.0,
                      fontWeight: FontWeight.w300,
                      color: Color(0XFF3F3D56),
                      height: 2.0)),
                  Text(
                    'Register your first account using the camera to scan a QRCode',
                    key: const Key('description'),
                    style: TextStyle(
                      color: Colors.grey,
                      letterSpacing: 1.2,
                      fontSize: 16.0,
                      height: 1.3),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          )
        ],
      )
    );
  }

}