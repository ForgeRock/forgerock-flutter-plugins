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
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/util/strings_util.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';
import 'package:provider/provider.dart';

class NotificationCard extends StatelessWidget {

  const NotificationCard({Key key, this.notification}) : super(key: key);

  final PushNotification notification;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: _notificationStatusIcon(notification),
        trailing: _notificationDateText(notification),
        title: _notificationTitle(context, notification),
    );
  }

  Widget _notificationStatusIcon(PushNotification notification) {
    return notification.approved
        ? Icon(
            Icons.check_circle,
            size: 24,
            color: Colors.green.shade500,
          )
        : notification.isExpired() && notification.pending
          ? Icon(
              Icons.error,
              size: 24,
              color: Colors.orange.shade300,
            )
          : notification.pending
            ? Icon(
                Icons.help,
                size: 30,
                color: Colors.grey.shade300,
              )
            : Icon(
                Icons.cancel,
                size: 30,
                color: Colors.red.shade800,
              );
  }

  Widget _notificationStatusText(BuildContext context, PushNotification notification) {
    return notification.approved
      ? TextScale(maxFactor: 1.3, child: Text(AppLocalizations.of(context).notificationCardApproved, style: const TextStyle(fontSize: 13, color: Colors.grey)))
      : notification.isExpired() && notification.pending
        ? TextScale(maxFactor: 1.3, child: Text(AppLocalizations.of(context).notificationCardExpired, style: const TextStyle(fontSize: 13, color: Colors.grey)))
        : notification.pending
          ? TextScale(maxFactor: 1.3, child: Text(AppLocalizations.of(context).notificationCardPending, style: const TextStyle(fontSize: 13, color: Colors.grey)))
          : TextScale(maxFactor: 1.3, child: Text(AppLocalizations.of(context).notificationCardDenied, style: const TextStyle(fontSize: 13, color: Colors.grey)));
  }

  Widget _notificationDateText(PushNotification notification) {
    final List<String> timeReceived = timestampToDateArray(notification.timeAdded);
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TextScale(maxFactor: 1.3, child: Text(timeReceived[0], style: const TextStyle(fontSize: 14, color: Colors.grey))),
              TextScale(maxFactor: 1.3, child: Text(timeReceived[1], style: const TextStyle(fontSize: 14, color: Colors.grey))),
            ])
    );
  }

  Widget _notificationTitle(BuildContext context, PushNotification notification) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextScale(maxFactor: 1.3, child: Text(
              '${AppLocalizations.of(context).notificationCardTitle} ${_getIssuer(context, notification)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
          ),
          _notificationStatusText(context, notification)
        ]);
  }

  String _getIssuer(BuildContext context, PushNotification notification) {
    final Account account = Provider
        .of<AuthenticatorProvider>(context, listen: false)
        .getAccountByMechanismUID(notification.mechanismUID);
    if (account != null) {
      return account.getIssuer();
    } else {
      return notification
          .getMechanism()
          .issuer;
    }
  }

}

