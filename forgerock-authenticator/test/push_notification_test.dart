/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';

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

    test('returns String representation of the Mechanism', () async {
      PushNotification pushNotification = PushNotification.fromJson(jsonDecode(pushNotificationJson));
      const String pushNotificationString = '{"id":"0585ace6-6e91-42bb-9a65-2f48f5212a20-100000","mechanismUID":"0585ace6-6e91-42bb-9a65-2f48f5212a20","messageId":"AUTHENTICATE:63ca6f18-7cfb-4198-bcd0-ac5041fbbea01583798229441","challenge":"fZl8wu9JBxdRQ7miq3dE0fbF0Bcdd+gRETUbtl6qSuM=","amlbCookie":"ZnJfc3NvX2FtbGJfcHJvZD0wMQ==","timeAdded":100000,"timeExpired":120000,"ttl":120,"approved":false,"pending":true}';
      expect(pushNotification.toString(), pushNotificationString);
    });

  });

}