/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';
import 'package:forgerock_authenticator_example/helpers/push_helper.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/screens/notifications/notifications_screen.dart';
import 'package:forgerock_authenticator_example/util/strings_util.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';
import 'package:provider/provider.dart';

class PushDetail extends StatelessWidget {

  const PushDetail({Key key, this.account}) : super(key: key);

  final Account account;

  @override
  Widget build(BuildContext context) {
    final List<String> lastSuccessfulLogin = getLastSuccessfulLogin(context);
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Column(
            children: <Widget>[
              InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<NotificationScreen>(builder: (BuildContext context) => const NotificationScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(11, 2, 0, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      TextScale(
                          maxFactor:1.1,
                          child: Text(
                              lastSuccessfulLogin[0],
                              softWrap: true,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600)
                          )
                      ),
                      TextScale(
                          maxFactor:1.1,
                          child: Text(
                              lastSuccessfulLogin[1],
                              softWrap: true,
                              style: const TextStyle(fontSize: 16, color: Colors.grey)
                          )
                      )
                    ]),
                  )
              )
            ],
          ),
          Column(
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.fromLTRB(6, 0, 8, 0),
                  child:SizedBox(
                      height: 48.0,
                      width: 48.0,
                      child: displayPushAction(context)
                  )
              )
            ],
          ),
        ], key: const Key('accountDetailVisible')
    );
  }

  Widget displayPushAction(BuildContext context) {
    final int count = Provider.of<AuthenticatorProvider>(context, listen: false).getPendingNotificationsCount(account: account);
    if (count == 0 || count == null) {
      return IconButton(
        padding: const EdgeInsets.fromLTRB(5, 0, 0, 10),
        color: Colors.grey[400],
        icon: const Icon(Icons.circle_notifications_outlined, size: 38.0, key: Key('notificationAction')),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<NotificationScreen>(builder: (BuildContext context) => const NotificationScreen()),
          );
        },
      );
    } else {
      return IconButton(
        padding: const EdgeInsets.fromLTRB(5, 0, 0, 10),
        color: Colors.grey[400],
        icon: Stack(
            children: <Widget>[
              const Icon(Icons.circle_notifications_outlined,  size: 38.0, key: Key('notificationAction')),
              Positioned(  // draw a red marble
                  top: 0.0,
                  right: 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                    alignment: Alignment.center,
                    child: Text(
                        '$count',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500
                        )
                    ),
                  )
              )
            ]
        ),
        onPressed: () {
            final PushNotification notification = Provider
                .of<AuthenticatorProvider>(context, listen: false)
                .getLatestNotification(account: account);
            if(notification.pending && !notification.isExpired()) {
              PushHelper().openNotificationDialog(context, notification);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute<NotificationScreen>(builder: (BuildContext context) => const NotificationScreen()),
              );
            }
        },
      );
    }
  }

  List<String> getLastSuccessfulLogin(BuildContext context) {
    final PushNotification notification = Provider.of<AuthenticatorProvider>(context, listen: false).getLatestNotification(account: account);
    if(notification != null) {
      return '${AppLocalizations.of(context).accountListLastAuthenticationAttempt}:#${timestampToDate(notification.timeAdded)}'.split('#');
    } else {
      return '${AppLocalizations.of(context).accountListLastAuthenticationAttempt}:#${AppLocalizations.of(context).accountListLastAuthenticationAttemptUnknown}'.split('#');
    }
  }

}