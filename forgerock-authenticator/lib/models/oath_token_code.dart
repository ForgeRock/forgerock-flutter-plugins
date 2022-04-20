/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'oath_mechanism.dart';

/// Represents a currently active OTP token.
class OathTokenCode {
  String? code;
  int? start;
  int? until;
  TokenType? oathType;

  /// Creates [OathTokenCode] object with given information.
  OathTokenCode(String? code, int? start, int? until, TokenType tokenType) {
    this.code = code;
    this.start = start;
    this.until = until;
    this.oathType = tokenType;
  }

  /// Deserializes the specified Json into an object of the [OathTokenCode] object.
  static OathTokenCode? fromMap(Map map) {
    if (map.isEmpty)
      return null;

    String type = map['oathType'];
    var oathType = type.toUpperCase() == 'HOTP' ? TokenType.HOTP : TokenType.TOTP;

    return OathTokenCode(map['code'], map['start'], map['until'], oathType);
  }

  /// Creates a JSON string representation of [OathTokenCode] object.
  Map<String, dynamic> toJson() => {
    'code': code,
    'start': start,
    'until': until,
    'oathType': oathType == TokenType.HOTP ? 'HOTP' : 'TOTP'
  };

  /// Creates a String representation of [OathTokenCode] object.
  String toString() => jsonEncode(toJson());

}