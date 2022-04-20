/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/screens/notifications/notification_list.dart';
import 'package:forgerock_authenticator_example/widgets/app_bar.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {

  const NotificationScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ForgeRockAppBar(
          actions: const <Widget>[],
          title: AppLocalizations.of(context).notificationScreenTitle,
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder<List<PushNotification>>(
          future: Provider.of<AuthenticatorProvider>(context, listen: false).getAllNotifications(),
          builder: (BuildContext context, AsyncSnapshot<List<PushNotification>> dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                return Center(
                  child: Text('${AppLocalizations.of(context).notificationScreenError} \n${dataSnapshot.error.toString()}'),
                );
              } else {
                return const NotificationList();
              }
            }
          }
        ),
      )
    );
  }

}
