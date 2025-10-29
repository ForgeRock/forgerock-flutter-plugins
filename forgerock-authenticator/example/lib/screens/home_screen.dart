/*
 * Copyright (c) 2022-2025 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forgerock_authenticator/forgerock_push_connector.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';
import 'package:provider/provider.dart';

import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/widgets/account_list.dart';
import 'package:forgerock_authenticator_example/widgets/actions_menu.dart';
import 'package:forgerock_authenticator_example/widgets/alert_dialog.dart';
import 'package:forgerock_authenticator_example/widgets/app_bar.dart';

import '../widgets/notification_dialog.dart';

/// This is the main screen of the app. It shows a list of accounts registered
/// with the SDK.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ForgerockPushConnector pushConnector = ForgerockPushConnector();

  @override
  void initState() {
    super.initState();
    _setupPushConnector();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scan(context),
        backgroundColor: Colors.orange,
        child: const Icon(
          Icons.qr_code_scanner,
          size: 30,
          color: Colors.white,
        ),
      ),
      appBar: const AuthenticatorAppBar(actions: [ActionsMenu()]),
      body: const AccountList(),
    );
  }

  void _setupPushConnector() {
    pushConnector.token.addListener(() {
      final token = pushConnector.token.value;
      if (token != null && token.isNotEmpty) {
        debugPrint('Token $token');
      }
    });

    pushConnector.pendingNotification.addListener(() {
      _processPendingNotification(
        pushConnector.pendingNotification.value as String?,
      );
    });
  }

  Future<void> _processPendingNotification(String? pendingNotification) async {
    if (pendingNotification == null || pendingNotification.isEmpty) {
      return;
    }
    final PushNotification notification =
        PushNotification.fromJson(jsonDecode(pendingNotification));
    if (notification.pending == true && !notification.isExpired()) {
      debugPrint('Processing pending notification with id ${notification.messageId}');
      if (!mounted) {
        return;
      }
      await showDialog<Widget>(
        context: context,
        builder: (BuildContext dialogContext) => NotificationDialog(
          pushNotification: notification,
        ),
      );
    }
  }

  Future<void> _scan(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    final BuildContext rootContext = navigator.context;
    try {
      final ScanResult result = await BarcodeScanner.scan();
      final String qrResult = result.rawContent;
      if (qrResult.isNotEmpty) {
        final authenticatorProvider =
            Provider.of<AuthenticatorProvider>(context, listen: false);
        try {
          await authenticatorProvider.addAccount(qrResult);
        } catch (error) {
          alert(rootContext, 'Error adding account via QRCode',
              error.toString());
        }
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        alert(context, 'Error', 'Camera access was not granted');
      } else {
        alert(context, 'Error', e.toString());
      }
    } catch (e) {
      alert(context, 'Error', e.toString());
    }
  }
}
