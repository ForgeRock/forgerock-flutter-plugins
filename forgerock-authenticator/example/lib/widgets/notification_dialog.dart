/*
 * Copyright (c) 2022-2025 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';

import 'package:forgerock_authenticator/models/push_notification.dart';
import 'package:forgerock_authenticator/models/push_type.dart';

import 'package:forgerock_authenticator_example/widgets/challenge_button.dart';
import 'package:forgerock_authenticator_example/widgets/default_button.dart';
import 'package:forgerock_authenticator_example/widgets/notification_box.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';

/// This widget is used inside an modal dialog to display a [PushNotification]
/// received by the app.
class NotificationDialog extends StatelessWidget {
  const NotificationDialog({super.key, required this.pushNotification});

  final PushNotification pushNotification;

  @override
  Widget build(BuildContext context) {
    return NotificationBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Push Authentication request',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
    if ((pushNotification.pushType?.isEqual(PushType.CHALLENGE) ?? false) &&
              (pushNotification.getNumbersChallenge()?.isNotEmpty ?? false))
            _challengeButtons(context)
          else
            _defaultButtons(context)
        ])
    );
  }

  Widget _defaultButtons(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Text(
          pushNotification.message ??
              'Do you wish to accept sign in from another device?',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultButton(
              key: const Key('accept-button'),
              action: () async {
                await _approve(true, context);
              },
              color: const Color(0xff006ac8),
              text: 'Accept',
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultButton(
              key: const Key('reject-button'),
              action: () async {
                await _approve(false, context);
              },
              color: Colors.black,
              text: 'Reject',
            ),
          ],
        ),
      ],
    );
  }

  Widget _challengeButtons(BuildContext context) {
    final List<String> challenge =
        pushNotification.getNumbersChallenge() ?? const <String>[];
    if (challenge.length < 3) {
      return const SizedBox.shrink();
    }
    return Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            'To continue with the Sign in, select the number you see on your other screen',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChallengeButton(
                key: const Key('challenge-option1-button'),
                action: () async {
                  await _approveWithChallenge(true, challenge.elementAt(2),
                      context);
                },
                text: challenge.elementAt(0),
              ),
              ChallengeButton(
                key: const Key('challenge-option2-button'),
                action: () async {
                  await _approveWithChallenge(true, challenge.elementAt(1),
                      context);
                },
                text: challenge.elementAt(1),
              ),
              ChallengeButton(
                key: const Key('challenge-option3-button'),
                action: () async {
                  await _approveWithChallenge(true, challenge.elementAt(2),
                      context);
                },
                text: challenge.elementAt(2),
              ),
            ],
          ),
          const SizedBox(height: 30),
          DefaultButton(
              key: const Key('reject-button'),
              action: () async {
                await _approveWithChallenge(false, null,
                    context);
              },
              color: Colors.black,
              text: 'Reject'
          ),
        ]);
  }

  Future<void> _approve(bool approve, BuildContext context) async {
    final NavigatorState navigator =
        Navigator.of(context, rootNavigator: true);
    final BuildContext rootContext = navigator.context;
    String message = 'Push Notification successfully processed.';
    try {
      if (pushNotification.pushType?.isEqual(PushType.BIOMETRIC) ?? false) {
        await AuthenticatorProvider.performPushAuthenticationWithBiometric(
          pushNotification,
          'Biometric is required to process this notification',
          true,
          approve,
        );
      } else {
        await AuthenticatorProvider.performPushAuthentication(
          pushNotification,
          approve,
        );
      }
    } catch (error) {
      message = error.toString();
    }
    _showResult(rootContext, message);
    Navigator.of(rootContext).pop();
  }

  Future<void> _approveWithChallenge(
      bool approve, String? challenge, BuildContext context) async {
    final NavigatorState navigator =
        Navigator.of(context, rootNavigator: true);
    final BuildContext rootContext = navigator.context;
    String message = 'Push Notification successfully processed.';
    try {
      await AuthenticatorProvider.performPushAuthenticationWithChallenge(
        pushNotification,
        challenge,
        approve,
      );
    } catch (error) {
      message = error.toString();
    }
    _showResult(rootContext, message);
    Navigator.of(rootContext).pop();
  }

  void _showResult(BuildContext context, String message) {
    final SnackBar snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}
