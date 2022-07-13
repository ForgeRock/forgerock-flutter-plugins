/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';
import 'package:forgerock_authenticator/models/push_type.dart';

import 'constants.dart';

void main() {

  group('PushNotification tests', () {
    test('returns a PushNotification if parse completes successfully', () async {
      PushNotification pushNotification = PushNotification.fromJson(jsonDecode(pushNotificationJson));
      expect(pushNotification.id, '0585ace6-6e91-42bb-9a65-2f48f5212a20-100000');
      expect(pushNotification.mechanismUID, '0585ace6-6e91-42bb-9a65-2f48f5212a20');
      expect(pushNotification.messageId, 'AUTHENTICATE:63ca6f18-7cfb-4198-bcd0-ac5041fbbea01583798229441');
      expect(pushNotification.ttl, 120);
      expect(pushNotification.approved, false);
      expect(pushNotification.pending, true);
      expect(pushNotification.numbersChallenge, null);
      expect(pushNotification.contextInfo, null);
      expect(pushNotification.customPayload, null);
      expect(pushNotification.pushType, PushType.DEFAULT);
    });

    test('returns a PushNotification if parse completes successfully for CHALLENGE type', () async {
      PushNotification pushNotification = PushNotification.fromJson(jsonDecode(challengePushNotificationJson));
      expect(pushNotification.id, '0c43c695-8d67-47f1-b575-1c7a83512060-1657238273273');
      expect(pushNotification.mechanismUID, '0c43c695-8d67-47f1-b575-1c7a83512060');
      expect(pushNotification.messageId, 'AUTHENTICATE:2b43a378-0013-4589-8e81-118be10559ac1657238273273');
      expect(pushNotification.message, 'Login attempt from user0 at ForgeRock-72');
      expect(pushNotification.pushType, PushType.CHALLENGE);
      expect(pushNotification.numbersChallenge, '27,64,71');
      expect(pushNotification.customPayload, '{  }');
      expect(pushNotification.contextInfo, '{ "location": { "latitude": 49.2306432, "longitude": -123.1126528 }, "remoteIp": "192.168.1.1", "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36" }');
    });

    test('returns a PushNotification if parse completes successfully for BIOMETRIC type', () async {
      PushNotification pushNotification = PushNotification.fromJson(jsonDecode(biometricPushNotificationJson));
      expect(pushNotification.id, '0c43c695-8d67-47f1-b575-1c7a83512060-1657238273273');
      expect(pushNotification.mechanismUID, '0c43c695-8d67-47f1-b575-1c7a83512060');
      expect(pushNotification.messageId, 'AUTHENTICATE:2b43a378-0013-4589-8e81-118be10559ac1657238273273');
      expect(pushNotification.message, 'Login attempt from user0 at ForgeRock-72');
      expect(pushNotification.pushType, PushType.BIOMETRIC);
      expect(pushNotification.numbersChallenge, null);
      expect(pushNotification.customPayload, '{  }');
      expect(pushNotification.contextInfo, '{ "location": { "latitude": 49.2306432, "longitude": -123.1126528 }, "remoteIp": "192.168.1.1", "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36" }');
    });

    test('returns List with number challenges', () async {
      PushNotification pushNotification = PushNotification.fromJson(jsonDecode(challengePushNotificationJson));
      expect(pushNotification.getNumbersChallenge()?.elementAt(0), '27');
      expect(pushNotification.getNumbersChallenge()?.elementAt(1), '64');
      expect(pushNotification.getNumbersChallenge()?.elementAt(2), '71');
    });

    test('returns contextual information as a Map', () async {
      PushNotification pushNotification = PushNotification.fromJson(jsonDecode(challengePushNotificationJson));
      Map<String, dynamic>? contextInfo = pushNotification.getContextInfo();
      expect(contextInfo?['remoteIp'], '192.168.1.1');
      expect(contextInfo?['location']['latitude'], 49.2306432);
      expect(contextInfo?['location']['longitude'], -123.1126528);
      expect(contextInfo?['userAgent'], 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36');
    });

    test('returns an JSON representation of the PushNotification object successfully', () async {
      PushNotification pushNotification = PushNotification.fromJson(jsonDecode(pushNotificationJson));
      final Map<String, dynamic> jsonMap = pushNotification.toJson();
      expect(jsonMap['id'], '0585ace6-6e91-42bb-9a65-2f48f5212a20-100000');
      expect(jsonMap['mechanismUID'], '0585ace6-6e91-42bb-9a65-2f48f5212a20');
      expect(jsonMap['messageId'], 'AUTHENTICATE:63ca6f18-7cfb-4198-bcd0-ac5041fbbea01583798229441');
      expect(jsonMap['ttl'], 120);
      expect(jsonMap['approved'], false);
      expect(jsonMap['pending'], true);
    });

    test('returns true when PushNotification is expired', () async {
      PushNotification pushNotification = PushNotification.fromJson(jsonDecode(pushNotificationJson));
      final Map<String, dynamic> jsonMap = pushNotification.toJson();
      expect(jsonMap['id'], '0585ace6-6e91-42bb-9a65-2f48f5212a20-100000');
      expect(jsonMap['mechanismUID'], '0585ace6-6e91-42bb-9a65-2f48f5212a20');
      expect(jsonMap['messageId'], 'AUTHENTICATE:63ca6f18-7cfb-4198-bcd0-ac5041fbbea01583798229441');
      expect(jsonMap['ttl'], 120);
      expect(jsonMap['approved'], false);
      expect(jsonMap['pending'], true);
      expect(pushNotification.isExpired(), true);
    });

    test('returns false when PushNotification is NOT expired', () async {
      final int time = DateTime.now().millisecondsSinceEpoch;
      final Map<String, dynamic> pushNotificationMap = <String, dynamic>{
        'mechanismUID':'0585ace6-6e91-42bb-9a65-2f48f5212a20',
        'messageId':'AUTHENTICATE:df927f41-1a06-43c7-98bc-d1f849a5c9a11629234567427',
        'challenge':'eLbUuPsShELasAdjqd9LI7zbFOaj2zAATO9c+hhfQv4=',
        'amlbCookie':'amlbcookie=01',
        'timeAdded':time,
        'timeExpired':time+120000,
        'ttl':120,
        'approved':false,
        'pending':true
      };
      final PushNotification pushNotification = PushNotification.fromJson(pushNotificationMap);

      expect(pushNotification.id, '0585ace6-6e91-42bb-9a65-2f48f5212a20-$time');
      expect(pushNotification.mechanismUID, '0585ace6-6e91-42bb-9a65-2f48f5212a20');
      expect(pushNotification.messageId, 'AUTHENTICATE:df927f41-1a06-43c7-98bc-d1f849a5c9a11629234567427');
      expect(pushNotification.ttl, 120);
      expect(pushNotification.approved, false);
      expect(pushNotification.pending, true);
      expect(pushNotification.isExpired(), false);
    });

    test('returns String representation of the PushNotification', () async {
      PushNotification pushNotification = PushNotification.fromJson(jsonDecode(pushNotificationJson));
      const String pushNotificationString = '{"id":"0585ace6-6e91-42bb-9a65-2f48f5212a20-100000","mechanismUID":"0585ace6-6e91-42bb-9a65-2f48f5212a20","messageId":"AUTHENTICATE:63ca6f18-7cfb-4198-bcd0-ac5041fbbea01583798229441","challenge":"fZl8wu9JBxdRQ7miq3dE0fbF0Bcdd+gRETUbtl6qSuM=","amlbCookie":"ZnJfc3NvX2FtbGJfcHJvZD0wMQ==","timeAdded":100000,"timeExpired":120000,"ttl":120,"approved":false,"pending":true,"customPayload":null,"numbersChallenge":null,"contextInfo":null,"pushType":"default"}';
      expect(pushNotification.toString(), pushNotificationString);
    });

  });

}