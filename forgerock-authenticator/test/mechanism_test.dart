/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:forgerock_authenticator/models/mechanism.dart';
import 'package:forgerock_authenticator/models/oath_mechanism.dart';
import 'package:forgerock_authenticator/models/push_mechanism.dart';

import 'constants.dart';

void main() {

  group('Mechanism tests', () {
    test('returns a HOTP Mechanism if parse completes successfully', () async {
        OathMechanism oathMechanism = Mechanism.fromJson(jsonDecode(hotpMechanismJson)) as OathMechanism;
        expect(oathMechanism.id, 'issuer1-user1-otpauth');
        expect(oathMechanism.mechanismUID, 'c112b325-ac22-37f1-aae6-c12cf411cf80');
        expect(oathMechanism.accountName, 'user1');
        expect(oathMechanism.issuer, 'issuer1');
        expect(oathMechanism.type, 'otpauth');
        expect(oathMechanism.oathType, TokenType.HOTP);
        expect(oathMechanism.digits, 8);
        expect(oathMechanism.algorithm, 'sha256');
        expect(oathMechanism.counter, 10);
    });

    test('returns a TOTP Mechanism if parse completes successfully', () async {
      OathMechanism oathMechanism = Mechanism.fromJson(jsonDecode(totpMechanismJson)) as OathMechanism;
      expect(oathMechanism.id, 'issuer1-user1-otpauth');
      expect(oathMechanism.mechanismUID, 'b162b325-ebb1-48e0-8ab7-b38cf341da95');
      expect(oathMechanism.accountName, 'user1');
      expect(oathMechanism.issuer, 'issuer1');
      expect(oathMechanism.type, 'otpauth');
      expect(oathMechanism.oathType, TokenType.TOTP);
      expect(oathMechanism.digits, 6);
      expect(oathMechanism.algorithm, 'sha1');
      expect(oathMechanism.period, 30);
    });

    test('returns a Push Mechanism if parse completes successfully', () async {
      PushMechanism pushMechanism = Mechanism.fromJson(jsonDecode(pushMechanismJson)) as PushMechanism;
      expect(pushMechanism.id, 'issuer1-user1-pushauth');
      expect(pushMechanism.mechanismUID, '0585ace6-6e91-42bb-9a65-2f48f5212a20');
      expect(pushMechanism.accountName, 'user1');
      expect(pushMechanism.issuer, 'issuer1');
      expect(pushMechanism.type, 'pushauth');
      expect(pushMechanism.authenticationEndpoint, 'https://example.com/am/json/push/sns/message?_action=authenticate');
    });

    test('returns an JSON representation of the Mechanism object successfully', () async {
      Mechanism mechanism = Mechanism.fromJson(jsonDecode(hotpMechanismJson));
      final Map<String, dynamic> jsonMap = mechanism.toJson();
      expect(jsonMap['id'], 'issuer1-user1-otpauth');
      expect(jsonMap['accountName'], 'user1');
      expect(jsonMap['issuer'], 'issuer1');
      expect(jsonMap['type'], 'otpauth');
    });

    test('returns an JSON representation of the OathMechanism object successfully', () async {
      OathMechanism mechanism = Mechanism.fromJson(jsonDecode(hotpMechanismJson)) as OathMechanism;
      final Map<String, dynamic> jsonMap = mechanism.toJson();
      expect(jsonMap['id'], 'issuer1-user1-otpauth');
      expect(jsonMap['accountName'], 'user1');
      expect(jsonMap['issuer'], 'issuer1');
      expect(jsonMap['type'], 'otpauth');
      expect(jsonMap['digits'], 8);
      expect(jsonMap['algorithm'], 'sha256');
      expect(jsonMap['counter'], 10);
    });

    test('returns an JSON representation of the PushMechanism object successfully', () async {
      PushMechanism mechanism = Mechanism.fromJson(jsonDecode(pushMechanismJson)) as PushMechanism;
      final Map<String, dynamic> jsonMap = mechanism.toJson();
      expect(jsonMap['id'], 'issuer1-user1-pushauth');
      expect(jsonMap['accountName'], 'user1');
      expect(jsonMap['issuer'], 'issuer1');
      expect(jsonMap['type'], 'pushauth');
      expect(jsonMap['mechanismUID'], '0585ace6-6e91-42bb-9a65-2f48f5212a20');
      expect(jsonMap['authenticationEndpoint'], 'https://example.com/am/json/push/sns/message?_action=authenticate');
    });

    test('returns String representation of the Mechanism', () async {
      Mechanism mechanism = Mechanism.fromJson(jsonDecode(totpMechanismJson));
      const String mechanismString = '{"id":"issuer1-user1-otpauth","issuer":"issuer1","accountName":"user1","mechanismUID":"b162b325-ebb1-48e0-8ab7-b38cf341da95","oathType":"TOTP","type":"otpauth","algorithm":"sha1","secret":"REMOVED","digits":6,"counter":null,"period":30,"timeAdded":null}';
      expect(mechanism.toString(), mechanismString);
    });

  });

}