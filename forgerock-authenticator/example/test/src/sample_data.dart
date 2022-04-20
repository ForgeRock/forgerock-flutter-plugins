/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator/models/mechanism.dart';
import 'package:forgerock_authenticator/models/oath_mechanism.dart';
import 'package:forgerock_authenticator/models/push_mechanism.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';
import 'randomizer.dart';

mixin SampleData {
  static const String randomChars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  static const String mechanism1String = '[{'
      '"id":"issuer1-user1-otpauth",'
      '"issuer":"issuer1",'
      '"accountName":"user1",'
      '"mechanismUID":"b162b325-ebb1-48e0-8ab7-b38cf341da95",'
      '"secret":"REMOVED",'
      '"type":"otpauth",'
      '"oathType":"TOTP",'
      '"algorithm":"sha1",'
      '"digits":6,'
      '"period":30'
      '}]';

  static const String account1String = '{'
      '"id":"issuer1-user1",'
      '"issuer":"issuer1",'
      '"accountName":"user1",'
      '"imageURL":"https:\\/\\/avatars.githubusercontent.com\\/u\\/2592818",'
      '"backgroundColor":"032b75",'
      '"timeAdded":100000,'
      '"mechanismList":$mechanism1String'
      '}';

  static final dynamic account1Json = jsonDecode(account1String);

  static const String mechanism2String = '[{'
      '"id":"issuer2-user2-otpauth",'
      '"issuer":"issuer2",'
      '"accountName":"user2",'
      '"mechanismUID":"a162b412-acb2-38e1-7bc1-b38cf341db32",'
      '"secret":"REMOVED",'
      '"type":"otpauth",'
      '"oathType":"HOTP",'
      '"algorithm":"sha256",'
      '"digits":6,'
      '"period":60'
      '}]';

  static const String account2String = '{'
      '"id":"issuer2-user2",'
      '"issuer":"issuer2",'
      '"accountName":"user2",'
      '"imageURL":"https:\\/\\/avatars.githubusercontent.com\\/u\\/2592818",'
      '"backgroundColor":"032b75",'
      '"timeAdded":100000,'
      '"mechanismList":$mechanism2String'
      '}';

  static final dynamic account2Json = jsonDecode(account2String);

  static const String mechanism3String = '[{'
      '"id":"issuer3-user3-otpauth",'
      '"issuer":"issuer3",'
      '"accountName":"user3",'
      '"mechanismUID":"d062b433-dcb1-57e2-5bc2-c12cf341da41",'
      '"secret":"REMOVED",'
      '"type":"otpauth",'
      '"oathType":"HOTP",'
      '"algorithm":"sha256",'
      '"digits":8,'
      '"period":60'
      '}]';

  static const String account3String = '{'
      '"id":"issuer3-user3",'
      '"issuer":"issuer3",'
      '"accountName":"user3",'
      '"backgroundColor":"032b75",'
      '"timeAdded":100000,'
      '"mechanismList":$mechanism3String'
      '}';

  static final dynamic account3Json = jsonDecode(account3String);

  static const String mechanism4String = '[{'
      '"id":"issuer4-user4-pushauth",'
      '"issuer":"issuer4",'
      '"accountName":"user4",'
      '"mechanismUID":"0585ace6-6e91-42bb-9a65-2f48f5212a20",'
      '"secret":"bkTMBWVZGLnfPL+AHql/o2XIV8WqIUIIfugEphtKYlc=",'
      '"type":"pushauth",'
      '"registrationEndpoint":"https://example.com/am/json/push/sns/message?_action=register",'
      '"authenticationEndpoint":"https://example.com/am/json/push/sns/message?_action=authenticate"'
      '}]';

  static const String account4String = '{'
      '"id":"issuer4-user4",'
      '"issuer":"issuer4",'
      '"accountName":"user4",'
      '"backgroundColor":"032b75",'
      '"timeAdded":100000,'
      '"mechanismList":$mechanism4String'
      '}';

  static final dynamic account4Json = jsonDecode(account4String);

  static Account createRandomAccount([String type, TokenType oathType]) {
    final Randomizer randomizer = Randomizer();
    final String id = 'RANDOM-ID-${randomizer.getRandomString(5)}';
    final String issuer = 'RANDOM-ISSUER-${randomizer.getRandomString(5)}';
    final String accountName = 'RANDOM-ACC-NAME-${randomizer.getRandomString(5)}';

    final Mechanism m = createRandomMechanism(issuer, accountName, type, oathType);
    final List<Mechanism> mechanismList = <Mechanism>[];
    mechanismList.add(m);
    return Account(id, issuer, null, accountName, null, null, null, null, mechanismList);
  }

  static Account createIndexedAccount(int index, [String type, TokenType oathType]) {
    final String id = 'ACCOUNT-ID-${index.toString().padLeft(3, '0')}';
    final String issuer = 'ACCOUNT-ISSUER-${index.toString().padLeft(3, '0')}';
    final String accountName = 'ACCOUNT-NAME-${index.toString().padLeft(3, '0')}';

    final Mechanism m = createRandomMechanism(issuer, accountName, type, oathType);
    final List<Mechanism> mechanismList = <Mechanism> [];
    mechanismList.add(m);
    return Account(id, issuer, null, accountName, null, null, null, null, mechanismList);
  }

  static Mechanism createRandomMechanism(String issuer, String accountName, [String type, TokenType oathType]) {
    if (type == null || type == Mechanism.OATH) {
      return createRandomOathMechanism(issuer, accountName, oathType);
    }
    else if (type == Mechanism.PUSH) {
      return createRandomPushMechanism(issuer, accountName);
    }
    else {
      return null;
    }
  }

  /// Return a random OATH mechanism for a specified [issuer] and [accountName].
  /// [oathType] param (optional) - specifies the type of the OATH mechanism to be created. "TOTP" by default.
  static OathMechanism createRandomOathMechanism(String issuer, String accountName, [TokenType oathType]) {
    final Randomizer randomizer = Randomizer();
    final String id = randomizer.getRandomString(16);
    final String mechanismUid = randomizer.getRandomString(36);

    // Default to TOTP
    oathType ??= TokenType.TOTP;
    return OathMechanism(
        id,
        mechanismUid,
        issuer,
        accountName,
        Mechanism.OATH,
        oathType == TokenType.HOTP ? TokenType.HOTP : TokenType.TOTP,
        'sha256',
        'REMOVED',
        6,
        30,
        30,
        100000
    );
  }

  /// Return a random PUSH mechanism for specified [issuer] and [accountName]
  static PushMechanism createRandomPushMechanism([String issuer, String accountName]) {
    final Randomizer randomizer = Randomizer();
    issuer ??= randomizer.getRandomIssuer();
    accountName ??= randomizer.getRandomAccountName(issuer);

    final int now = getTimeStampNow();

    return PushMechanism(
        randomizer.getRandomString(16),
        randomizer.getRandomString(36),
        issuer,
        accountName,
        Mechanism.PUSH,
        'REMOVED',
        'https://example.com/am/json/push/sns/message?_action=register',
        'https://example.com/am/json/push/sns/message?_action=authenticate',
        randomizer.getRandomInt(now - (1200 * 1000), now)
    );
  }

  /// Return a random PUSH notification.
  /// timeAdded is random time within the past 20 minutes from 'now'
  /// timeExpired is random time within the next 2 minutes from 'now'
  static PushNotification createRandomPushNotification() {
    final Randomizer randomizer = Randomizer();
    final int now = getTimeStampNow();

    final PushNotification pushNotification =  PushNotification(
        randomizer.getRandomString(16),
        'AUTHENTICATE:${randomizer.getRandomString(16)}',
        'REMOVED',
        'REMOVED',
        randomizer.getRandomInt(now - (1200 * 1000), now),
        randomizer.getRandomInt(now, now + (120 * 1000)),
        randomizer.getRandomInt(0, 360),
        randomizer.getRandomBool(),
        randomizer.getRandomBool());

    final PushMechanism pushMechanism = createRandomPushMechanism();
    pushNotification.setMechanism(pushMechanism);
    return pushNotification;
  }

  /// Return a PUSH notification with specified [issuer], [timeAdded], [timeExpired], [approved] and [pending]
  static PushNotification createPushNotification(
      String issuer,
      int timeAdded,
      int timeExpired,
      bool approved,
      bool pending) {

    final Randomizer randomizer = Randomizer();
    final PushNotification pushNotification =  PushNotification(
        randomizer.getRandomString(16),
        'AUTHENTICATE:${randomizer.getRandomString(16)}',
        'REMOVED',
        'REMOVED',
        timeAdded,
        timeExpired,
        randomizer.getRandomInt(0, 360),
        approved,
        pending);

    final PushMechanism pushMechanism = createRandomPushMechanism(issuer);
    pushNotification.setMechanism(pushMechanism);
    return pushNotification;
  }

  static int getTimeStampNow() => DateTime.now().millisecondsSinceEpoch;

  /// ToDo: remove this example...:
  //pushauth://push/forgerock:Stoyan%20Petrov?a=aHR0cHM6Ly9vcGVuYW0tZm9yZ2Vycm9jay1zZGtzLmZvcmdlYmxvY2tzLmNvbTo0NDMvYW0vanNvbi9hbHBoYS9wdXNoL3Nucy9tZXNzYWdlP19hY3Rpb249YXV0aGVudGljYXRl&r=aHR0cHM6Ly9vcGVuYW0tZm9yZ2Vycm9jay1zZGtzLmZvcmdlYmxvY2tzLmNvbTo0NDMvYW0vanNvbi9hbHBoYS9wdXNoL3Nucy9tZXNzYWdlP19hY3Rpb249cmVnaXN0ZXI&b=032b75&s=UPfxg240lYxAvhWiveZqP8zevUbiVihdpnS7R62FC5s&c=oWXRuAlr2t0uNky_15SwX8RAIRXFM-clomHZNwxHnJw&l=YW1sYmNvb2tpZT0wMQ&m=REGISTER:0aa79f5c-ce46-4911-81b3-3cdad29102ca1629173979859&issuer=Rm9yZ2VSb2Nr
}