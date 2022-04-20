/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';
import 'package:forgerock_authenticator_example/helpers/push_helper.dart';
import 'package:provider/provider.dart';

import '/providers/authenticator_provider.dart';
import '../../widgets/empty_list.dart';
import 'notification_card.dart';

class NotificationList extends StatelessWidget {

  const NotificationList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticatorProvider>(
      builder: (BuildContext context, AuthenticatorProvider authenticatorProvider, Widget child) {
        if (authenticatorProvider.notifications.isNotEmpty) {
          return ListView.separated(
            itemCount: authenticatorProvider.notifications.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                  onTap: () {
                    openNotificationDialog(context, authenticatorProvider.notifications[index]);
                  },
                  child: NotificationCard(
                      key: ValueKey<int>(authenticatorProvider.notifications[index].timeAdded),
                      notification: authenticatorProvider.notifications[index]
                  )
                );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                height: 10,
                thickness: 1,
                indent: 10,
                endIndent: 10,
              );
            }
          );
        } else {
          return EmptyList(
            image: 'assets/images/fr-icon-no-notifications.png',
            header: AppLocalizations.of(context).noNotificationListHeader,
            description: AppLocalizations.of(context).noNotificationListDescription,
          );
        }
      }
    );
  }

  void openNotificationDialog(BuildContext context, PushNotification notification) {
    if (!notification.isExpired() && !notification.approved) {
      PushHelper().openNotificationDialog(context, notification);
    }
  }

}
