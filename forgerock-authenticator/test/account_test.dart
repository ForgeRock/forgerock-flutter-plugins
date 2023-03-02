/*
 * Copyright (c) 2022-2023 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator/models/oath_mechanism.dart';
import 'package:forgerock_authenticator/models/push_mechanism.dart';

import 'constants.dart';

void main() {

  group('Account tests', () {
    test('returns an Account with no mechanisms if parse completes successfully', () async {
        Account account = Account.fromJson(jsonDecode(accountJson));
        expect(account.id, 'issuer1-user1');
        expect(account.accountName, 'user1');
        expect(account.issuer, 'issuer1');
        expect(account.imageURL, 'http://forgerock.com/logo.jpg');
        expect(account.backgroundColor, '032b75');
        expect(account.timeAdded, 100000);
    });

    test('returns an Account with with mechanisms if parse completes successfully', () async {
      Account account = Account.fromJson(jsonDecode(accountWithOathMechanismJson));
      expect(account.id, 'issuer1-user1');
      expect(account.accountName, 'user1');
      expect(account.issuer, 'issuer1');
      expect(account.imageURL, 'http://forgerock.com/logo.jpg');
      expect(account.backgroundColor, '032b75');
      expect(account.timeAdded, 100000);
      expect(account.mechanismList, isNotEmpty);
    });

    test('returns an JSON representation of the Account object successfully', () async {
      Account account = Account.fromJson(jsonDecode(accountWithOathMechanismJson));
      final Map<String, dynamic> jsonMap = account.toJson();
      expect(jsonMap['id'], 'issuer1-user1');
      expect(jsonMap['accountName'], 'user1');
      expect(jsonMap['issuer'], 'issuer1');
      expect(jsonMap['imageURL'], 'http://forgerock.com/logo.jpg');
      expect(jsonMap['backgroundColor'], '032b75');
      expect(jsonMap['timeAdded'], 100000);
      expect(jsonMap['mechanismList'], isNotEmpty);
    });

    test('returns the Account name and Issuer name of the account', () async {
      Account account = Account.fromJson(jsonDecode(accountWithOathMechanismJson));
      expect(account.getAccountName(), 'user1');
      expect(account.getIssuer(), 'issuer1');
    });

    test('returns the alternative Account name and Issuer name of the account', () async {
      const String accountJson = "{" +
          "\"id\":\"issuer1-user1\"," +
          "\"issuer\":\"issuer1\"," +
          "\"displayIssuer\":\"alternative-issuer1\"," +
          "\"accountName\":\"user1\"," +
          "\"displayAccountName\":\"alternative-user1\"," +
          "\"imageURL\":\"http:\\/\\/forgerock.com\\/logo.jpg\"," +
          "\"backgroundColor\":\"032b75\"," +
          "\"timeAdded\":100000" +
          "}";
      Account account = Account.fromJson(jsonDecode(accountJson));
      expect(account.getAccountName(), 'alternative-user1');
      expect(account.getIssuer(), 'alternative-issuer1');
    });

    test('returns the OATH mechanism associated with the account', () async {
      Account account = Account.fromJson(jsonDecode(accountWithOathMechanismJson));
      OathMechanism? oathMechanism = account.getOathMechanism();
      expect(account.hasOathMechanism(), true);
      expect(account.hasMultipleMechanisms(), false);
      expect(oathMechanism!.type, 'otpauth');
      expect(oathMechanism.mechanismUID, 'b162b325-ebb1-48e0-8ab7-b38cf341da95');
      expect(oathMechanism.algorithm, 'sha1');
      expect(oathMechanism.period, 30);
      expect(oathMechanism.digits, 6);
    });

    test('returns the Push mechanism associated with the account', () async {
      Account account = Account.fromJson(jsonDecode(accountWithPushMechanismJson));
      PushMechanism? pushMechanism = account.getPushMechanism();
      expect(account.hasPushMechanism(), true);
      expect(account.hasMultipleMechanisms(), false);
      expect(pushMechanism!.type, 'pushauth');
      expect(pushMechanism.mechanismUID, '0585ace6-6e91-42bb-9a65-2f48f5212a20');
      expect(pushMechanism.authenticationEndpoint, 'https://example.com/am/json/push/sns/message?_action=authenticate');
    });

    test('returns the all mechanisms associated with the account', () async {
      Account account = Account.fromJson(jsonDecode(accountWithPushAndOathMechanismsJson));
      PushMechanism? pushMechanism = account.getPushMechanism();
      OathMechanism? oathMechanism = account.getOathMechanism();
      expect(account.hasPushMechanism(), true);
      expect(account.hasOathMechanism(), true);
      expect(account.hasMultipleMechanisms(), true);
      expect(pushMechanism!.type, 'pushauth');
      expect(pushMechanism.mechanismUID, '0585ace6-6e91-42bb-9a65-2f48f5212a20');
      expect(pushMechanism.authenticationEndpoint, 'https://example.com/am/json/push/sns/message?_action=authenticate');
      expect(oathMechanism!.type, 'otpauth');
      expect(oathMechanism.mechanismUID, 'b162b325-ebb1-48e0-8ab7-b38cf341da95');
      expect(oathMechanism.algorithm, 'sha1');
    });

    test('returns String representation of the account', () async {
      Account account = Account.fromJson(jsonDecode(accountJson));
      const String accountString = '{"id":"issuer1-user1","issuer":"issuer1","displayIssuer":null,"accountName":"user1","displayAccountName":null,"imageURL":"http://forgerock.com/logo.jpg","backgroundColor":"032b75","timeAdded":100000,"policies":null,"lockingPolicy":null,"lock":false,"mechanismList":[]}';
      expect(account.hasOathMechanism(), false);
      expect(account.hasPushMechanism(), false);
      expect(account.toString(), accountString);
    });
  });

}