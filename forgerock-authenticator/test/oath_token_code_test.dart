/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:forgerock_authenticator/models/oath_mechanism.dart';
import 'package:forgerock_authenticator/models/oath_token_code.dart';

import 'constants.dart';

void main() {

  group('OathTokenCode tests', () {
    test('returns a OathTokenCode if parse completes successfully', () async {
      OathTokenCode? oathTokenCode = OathTokenCode.fromJson(jsonDecode(oathTokenCodeJson));
      expect(oathTokenCode.oathType, TokenType.HOTP);
      expect(oathTokenCode.start, 10000);
      expect(oathTokenCode.until, 10030);
      expect(oathTokenCode.code, '123456');
    });

    test('returns an JSON representation of the OathTokenCode object successfully', () async {
      OathTokenCode? oathTokenCode = OathTokenCode.fromJson(jsonDecode(oathTokenCodeJson));
      final Map<String, dynamic> jsonMap = oathTokenCode.toJson();
      expect(jsonMap['oathType'], 'HOTP');
      expect(jsonMap['code'], '123456');
      expect(jsonMap['start'], 10000);
      expect(jsonMap['until'], 10030);
    });

    test('returns String representation of the Mechanism', () async {
      OathTokenCode? oathTokenCode = OathTokenCode.fromJson(jsonDecode(oathTokenCodeJson));
      const String oathTokenCodeString = '{"code":"123456","start":10000,"until":10030,"oathType":"HOTP"}';
      expect(oathTokenCode.toString(), oathTokenCodeString);
    });

  });

}