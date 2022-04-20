/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';
import 'package:forgerock_authenticator_example/helpers/diagnostic_logger.dart';
import 'package:forgerock_authenticator_example/helpers/push_helper.dart';
import 'package:forgerock_authenticator_example/widgets/account_logo.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';

class NotificationDialog extends StatefulWidget {

  const NotificationDialog({Key key, this.account, this.pushNotification}) : super(key: key);

  final Account account;
  final PushNotification pushNotification;

  @override
  NotificationDialogState createState() => NotificationDialogState();
}

class NotificationDialogState extends State<NotificationDialog> with WidgetsBindingObserver {

  String _errorMessage;
  bool _errorVisible = false;
  bool _approvalVisible = true;

  String get messageId => widget.pushNotification.messageId;

  @override
  void initState() {
    super.initState();
    DiagnosticLogger.fine('New notification dialog displayed for messageId: $messageId');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context){
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(left: 20, top: 80, right: 20, bottom: 20),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextScale(child: Text(widget.account != null
                    ? '${AppLocalizations.of(context).notificationDialogHeaderWithIssuer} ${widget.account.getIssuer()}'
                    : AppLocalizations.of(context).notificationDialogHeaderNoIssuer,
                style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w600),textAlign: TextAlign.center,)
              ),
              const SizedBox(height: 15),
              _approvalSection(),
              _errorSection(),
              const SizedBox(width: 15),
            ],
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: _accountLogo()
        ),
      ],
    );
  }

  Widget _accountLogo() {
    if(widget.account != null) {
      return Container(
          alignment: Alignment.center,
          width: 50,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: AccountLogo(account: widget.account)
      );
    } else {
      return Container();
    }
  }

  Widget _approvalSection() {
    return Visibility(
        key: const Key('approval-section'),
        visible: _approvalVisible,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextScale(child: Text(
                AppLocalizations.of(context).notificationDialogMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                ),
              )
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                    key: const Key('accept-button'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: const Color(0xFF006AC8),
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      minimumSize: const Size.fromHeight(45),
                    ),
                    onPressed: () async {
                      await _approve(true);
                    },
                    child: TextScale(child: Text(
                      AppLocalizations.of(context).notificationDialogApproveButton,
                      style: const TextStyle(fontSize: 18),
                    ))
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    key: const Key('reject-button'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: Colors.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      minimumSize: const Size.fromHeight(45),
                    ),
                    onPressed: () async {
                      await _approve(false);
                    },
                    child: TextScale(child: Text(
                      AppLocalizations.of(context).notificationDialogRejectButton,
                      style: const TextStyle(fontSize: 18),
                    ))
                )
              ],
            ),
          ])
    );
  }

  Widget _errorSection() {
    return Visibility(
      key: const Key('error-section'),
      visible: _errorVisible,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextScale(child: Text(
              _errorMessage ??= AppLocalizations.of(context).notificationDialogError,
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center
            )
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              key: const Key('ok-button'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                primary: const Color(0xFF006AC8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                minimumSize: const Size.fromHeight(42),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: TextScale(child: Text(
                AppLocalizations.of(context).notificationDialogOkButton,
                style: const TextStyle(fontSize: 18),))
          ),
        ])
    );
  }


  Future<void> _approve(bool approve) async {
    final BuildContext rootContext = context.findRootAncestorStateOfType<NavigatorState>().context;
    await PushHelper().performPushAuthentication(widget.pushNotification, approve)
        .catchError((Object error) {
          DiagnosticLogger.fine('Error on approve/deny push notification.', error);
          if(mounted) {
            setState(() {
              _errorVisible = true;
              _approvalVisible = false;
              _errorMessage = AppLocalizations.of(rootContext).notificationDialogCustomError;
            });
          }
        })
        .then((Object value) {
          if(mounted && _approvalVisible) {
            _showSuccessResult(rootContext);
            Navigator.of(rootContext).pop();
          }
        });
  }

  void _showSuccessResult(BuildContext context) {
    final SnackBar snackBar = SnackBar(
      content: Text(AppLocalizations.of(context).notificationDialogSuccess,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: MediaQuery.of(context).size.height > 800 ? 18 : 16,
            height: 1.3, color: Colors.white,
            fontWeight: FontWeight.w500
        ),
      ),
      backgroundColor: const Color(0xFF34A853),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void dismiss() {
    DiagnosticLogger.fine('Dismiss notification dialog with messageId: $messageId');
    Navigator.of(context).pop();
  }

}
