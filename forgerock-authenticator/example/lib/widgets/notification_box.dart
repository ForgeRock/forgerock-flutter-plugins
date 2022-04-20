/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

/// This widget is used to decorate a notification dialog.
class NotificationBox extends StatelessWidget {

  final Widget child;

  const NotificationBox({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 20, top: 65, right: 20, bottom: 20),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,offset: Offset(0,5),
                  blurRadius: 10
                ),
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Push Authentication request',
                  style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w600),textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                child,
                const SizedBox(width: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
