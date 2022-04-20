/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator/forgerock_push_connector.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/screens/notifications/notification_dialog.dart';
import 'package:provider/provider.dart';

/// This Helper class is used to handle Push Notifications tasks, shuch as registration, storage, and display.
class PushHelper {

  factory PushHelper([BuildContext context]) {
    if (context != null) {
      _instance._context = context;
    }
    return _instance;
  }

  PushHelper._internal() {
    pushConnector.token.addListener(() {
      print('Token ${pushConnector.token.value}');
    });

    pushConnector.pendingNotification.addListener(() {
      processPendingNotification();
    });
  }

  static final PushHelper _instance = PushHelper._internal();

  final ForgerockPushConnector pushConnector = ForgerockPushConnector();

  GlobalKey<NotificationDialogState> notificationDialogKey = GlobalKey();
  BuildContext _context;

  void setContext(BuildContext context) {
    print('Setting Context: $context');
    _context = context;
  }

  Future<void> processPendingNotification({BuildContext context}) async {
    if(context != null) {
      print('Setting Context: $context');
      _context = context;
    }

    if(_context != null) {
      print('Checking pending notifications...');
      final List<PushNotification> list = await Provider
          .of<AuthenticatorProvider>(_context, listen: false)
          .refreshNotifications();

      if(list != null && list.isNotEmpty) {
        // process the last notification
        final PushNotification notification = list.first;
        if(notification.pending && !notification.isExpired()) {
          print('Processing pending notification with id ${notification.messageId}');
          openNotificationDialog(_context, notification);
        } else {
          print('No pending notification found.');
        }
      }
    } else {
      print('Context was not set.');
    }
  }

  void openNotificationDialog(BuildContext context, PushNotification notification) {
    if(notificationDialogKey.currentState != null && notificationDialogKey.currentState.mounted) {
      print('A notification dialog is already displayed...');
      if(notificationDialogKey.currentState.messageId != notification.messageId) {
        print('The notification dialog is from a different push request, dismissing to create a new one with latest...');
        notificationDialogKey.currentState.dismiss();
        _createNotificationDialog(context, notification);
      }
    } else {
      _createNotificationDialog(context, notification);
    }
  }

  void _createNotificationDialog(BuildContext context, PushNotification notification) {
    print('Creating new notification dialog...');
    notificationDialogKey = GlobalKey();

    final String mechanismUID = notification.mechanismUID;
    final Account account = Provider
        .of<AuthenticatorProvider>(context, listen: false)
        .getAccountByMechanismUID(mechanismUID);

    Future<void>.delayed(Duration.zero, () {
      showDialog<Widget>(context: context, builder: (BuildContext context) {
        return NotificationDialog(
          key: notificationDialogKey,
          account: account,
          pushNotification: notification,
        );
      });
    });
  }

  Future<bool> performPushAuthentication(PushNotification pushNotification, bool approved) async {
    final bool result = await Provider
        .of<AuthenticatorProvider>(_context, listen: false)
        .performPushAuthentication(pushNotification, approved)
        .catchError((Object error) {
          throw error;
        });

    return result;
  }

}