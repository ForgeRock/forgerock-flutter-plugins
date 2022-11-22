/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forgerock_authenticator/forgerock_authenticator.dart';
import 'package:forgerock_authenticator/models/oath_mechanism.dart';
import 'package:forgerock_authenticator/models/oath_token_code.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';

import 'constants.dart';

const MethodChannel channel = MethodChannel('forgerock_authenticator');
final List<MethodCall> methodCallLog = <MethodCall>[];

void main() {

  setUp(() {
    setupForgerockAuthenticatorMocks();
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('createMechanismFromUri', () async {
    expect(await ForgerockAuthenticator.createMechanismFromUri(hotpURI), isA<OathMechanism>());
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall(
        'createMechanismFromUri',
        arguments: <String, dynamic>{
          "uri": hotpURI
        },
      ),
    ]);
  });

  test('getAllAccounts', () async {
    expect(await ForgerockAuthenticator.getAllAccounts(), List.empty());
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall('getAllAccounts', arguments: null),
    ]);
  });

  test('updateAccount', () async {
    expect(await ForgerockAuthenticator.updateAccount(accountJson), isTrue);
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall(
        'updateAccount',
        arguments: <String, dynamic>{
          "accountJson": accountJson
        },
      ),
    ]);
  });

  test('removeAccount', () async {
    expect(await ForgerockAuthenticator.removeAccount("issuer1-user1"), isTrue);
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall(
        'removeAccount',
        arguments: <String, dynamic>{
          "accountId": "issuer1-user1"
        },
      ),
    ]);
  });

  test('removeMechanism', () async {
    expect(await ForgerockAuthenticator.removeMechanism("c112b325-ac22-37f1-aae6-c12cf411cf80"), isTrue);
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall(
        'removeMechanism',
        arguments: <String, dynamic>{
          "mechanismUID": "c112b325-ac22-37f1-aae6-c12cf411cf80"
        },
      ),
    ]);
  });

  test('removeAllNotifications', () async {
    expect(await ForgerockAuthenticator.removeAllNotifications(), isTrue);
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall('removeAllNotifications', arguments: null)
    ]);
  });

  test('getOathTokenCode', () async {
    expect(await ForgerockAuthenticator.getOathTokenCode("issuer1-user1"), isA<OathTokenCode>());
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall(
        'getOathTokenCode',
        arguments: <String, dynamic>{
          "mechanismId": "issuer1-user1"
        },
      ),
    ]);
  });

  test('getNotification', () async {
    expect(await ForgerockAuthenticator.getNotification("b162b325-ebb1-48e0-8ab7-b38cf341da95-100000"), isA<PushNotification>());
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall(
        'getNotification',
        arguments: <String, dynamic>{
          "notificationId": "b162b325-ebb1-48e0-8ab7-b38cf341da95-100000"
        },
      ),
    ]);
  });

  test('handleMessageWithPayload', () async {
    final Map<String, dynamic> userInfo = jsonDecode(apnsPayload);
    expect(await ForgerockAuthenticator.handleMessageWithPayload(userInfo), isA<PushNotification>());
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall(
        'handleMessageWithPayload',
        arguments: <String, dynamic>{
          "userInfo": userInfo
        },
      ),
    ]);
  });

  test('performPushAuthentication', () async {
    final PushNotification notification = PushNotification.fromJson(jsonDecode(pushNotificationJson));
    expect(await ForgerockAuthenticator.performPushAuthentication(notification, true), isTrue);
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall(
        'performPushAuthentication',
        arguments: <String, dynamic>{
          "notificationId": notification.id,
          "accept": true
        },
      ),
    ]);
  });

  test('performPushAuthenticationWithChallenge', () async {
    final PushNotification notification = PushNotification.fromJson(jsonDecode(challengePushNotificationJson));
    expect(await ForgerockAuthenticator.performPushAuthenticationWithChallenge(notification, "71", true), isTrue);
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall(
        'performPushAuthenticationWithChallenge',
        arguments: <String, dynamic>{
          "notificationId": notification.id,
          "challengeResponse": "71",
          "accept": true
        },
      ),
    ]);
  });

  test('performPushAuthenticationWithBiometric', () async {
    final PushNotification notification = PushNotification.fromJson(jsonDecode(challengePushNotificationJson));
    expect(await ForgerockAuthenticator.performPushAuthenticationWithBiometric(notification, "Title", true, true), isTrue);
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall(
        'performPushAuthenticationWithBiometric',
        arguments: <String, dynamic>{
          "notificationId": notification.id,
          "title": "Title",
          "allowDeviceCredentials": true,
          "accept": true
        },
      ),
    ]);
  });

  test('getAllNotifications', () async {
    expect(await ForgerockAuthenticator.getAllNotifications(), List.empty());
    expect(methodCallLog, hasLength(2));
    expect(methodCallLog, <Matcher>[
      isMethodCall('getAllMechanismsGroupByUID', arguments: null),
      isMethodCall('getAllNotifications', arguments: null)
    ]);
  });

  test('getAllNotificationsByAccountId', () async {
    expect(await ForgerockAuthenticator.getAllNotificationsByAccountId("issuer1-user1"), List.empty());
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall('getAllNotifications',
        arguments: <String, dynamic>{
          "accountId": "issuer1-user1"
        },),
    ]);
  });

  test('getPendingNotificationsCount', () async {
    expect(await ForgerockAuthenticator.getPendingNotificationsCount(), isA<int>());
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall('getPendingNotificationsCount', arguments: null)
    ]);
  });

  test('hasAlreadyLaunched', () async {
    expect(await ForgerockAuthenticator.hasAlreadyLaunched(), isTrue);
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall('hasAlreadyLaunched', arguments: null)
    ]);
  });

  test('disableScreenshot', () async {
    expect(await ForgerockAuthenticator.disableScreenshot(), isTrue);
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall('disableScreenshot', arguments: null)
    ]);
  });

  test('enableScreenshot', () async {
    expect(await ForgerockAuthenticator.enableScreenshot(), isTrue);
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall('enableScreenshot', arguments: null)
    ]);
  });

  test('getInitialLink', () async {
    expect(await ForgerockAuthenticator.getInitialLink(), isA<String>());
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall('getInitialLink', arguments: null)
    ]);
  });

  test('getInitialUri', () async {
    expect(await ForgerockAuthenticator.getInitialUri(), isA<Uri>());
    expect(methodCallLog, hasLength(1));
    expect(methodCallLog, <Matcher>[
      isMethodCall('getInitialLink', arguments: null)
    ]);
  });

}

void setupForgerockAuthenticatorMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    methodCallLog.add(methodCall);
    switch (methodCall.method) {
      case 'createMechanismFromUri':
        return hotpMechanismJson;
      case 'getOathTokenCode':
        return {
          'oathType': 'HOTP',
          'code': '123456',
          'start': 10000,
          'until': 10030
        };
      case 'getNotification':
      case 'handleMessageWithPayload':
        return pushNotificationJson;
      case 'getAllAccounts':
      case 'getAllNotifications':
      case 'getAllNotificationsByAccountId':
        return List.empty();
      case 'getPendingNotificationsCount':
        return 0;
      case 'getInitialLink':
        return totpURI;
      case 'updateAccount':
      case 'removeAccount':
      case 'removeMechanism':
      case 'removeAllNotifications':
      case 'hasAlreadyLaunched':
      case 'enableScreenshot':
      case 'disableScreenshot':
      case 'performPushAuthentication':
        return true;
      case 'performPushAuthenticationWithChallenge':
        return true;
      case 'performPushAuthenticationWithBiometric':
        return true;
      default:
        return null;
    }
  });
  methodCallLog.clear();
}