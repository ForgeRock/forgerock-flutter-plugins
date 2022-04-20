/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

import 'package:forgerock_authenticator/models/push_notification.dart';

import 'package:forgerock_authenticator_example/widgets/notification_box.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';

/// This widget is used inside an modal dialog to display a [PushNotification]
/// received by the app.
class NotificationDialog extends StatelessWidget {

  const NotificationDialog({Key key, this.pushNotification}) : super(key: key);

  final PushNotification pushNotification;

  @override
  Widget build(BuildContext context) {
    return NotificationBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Do you wish to accept sign in from another computer?',
            style: const TextStyle(fontSize: 14),textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                key: const Key('accept-button'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  shadowColor: Colors.greenAccent,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0)),
                  minimumSize: const Size(120, 40),
                ),
                onPressed: () async {
                  await _approve(true, context);
                },
                child: Text(
                  'Accept',
                  style: const TextStyle(fontSize: 14),
                )
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                key: const Key('reject-button'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                  shadowColor: Colors.redAccent,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0)),
                  minimumSize: const Size(120, 40),
                ),
                onPressed: () async {
                  await _approve(false, context);
                },
                child: Text(
                  'Reject',
                  style: const TextStyle(fontSize: 14),
                )
              )
            ],
          ),
        ])
    );
  }

  Future<void> _approve(bool approve, BuildContext context) async {
    final BuildContext rootContext = context.findRootAncestorStateOfType<NavigatorState>().context;
    String message = 'Push Notification successfully processed.';
    await AuthenticatorProvider.performPushAuthentication(pushNotification, approve)
      .catchError((Object error) {
        message = error.toString();
      })
      .then((Object value) {
        _showResult(rootContext, message);
        Navigator.of(rootContext).pop();
      });
  }

  void _showResult(BuildContext context, String message) {
    final SnackBar snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}
