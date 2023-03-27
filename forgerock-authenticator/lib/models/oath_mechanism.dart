/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'account.dart';
import 'mechanism.dart';

enum TokenType { HOTP, TOTP }

/// Represents an instance of a OATH authentication mechanism. Associated with an [Account].
class OathMechanism extends Mechanism {
  TokenType? oathType;
  String? algorithm;
  int? digits;
  int? counter;
  int? period;

  /// Creates [OathMechanism] object with given information.
  OathMechanism(
      String? id,
      String? mechanismUID,
      String? issuer,
      String? accountName,
      String? type,
      TokenType oathType,
      String? algorithm,
      String? secret,
      int? digits,
      int? counter,
      int? period,
      int? timeAdded,
      [Account? account])
      : super(id, mechanismUID, issuer, accountName, type, secret, timeAdded,
            account) {
    this.oathType = oathType;
    this.algorithm = algorithm;
    this.digits = digits;
    this.counter = counter;
    this.period = period;
  }

  /// Deserializes the specified Json into an object of the [OathMechanism] object.
  factory OathMechanism.fromJson(Map<String, dynamic> json,
      [Account? account]) {
    return OathMechanism(
        json['id'],
        json['mechanismUID'],
        json['issuer'],
        json['accountName'],
        json['type'],
        json['oathType'].toUpperCase() == 'HOTP'
            ? TokenType.HOTP
            : TokenType.TOTP,
        json['algorithm'],
        json['secret'],
        json['digits'] is String
            ? int.tryParse(json['digits'])
            : json['digits'],
        json['counter'] is String
            ? int.tryParse(json['counter'])
            : json['counter'],
        json['period'] is String
            ? int.tryParse(json['period'])
            : json['period'],
        json['timeAdded'],
        account);
  }

  /// Creates a JSON string representation of [OathMechanism] object.
  Map<String, dynamic> toJson() => {
        'id': id,
        'issuer': issuer,
        'accountName': accountName,
        'mechanismUID': mechanismUID,
        'oathType': oathType == TokenType.HOTP ? 'HOTP' : 'TOTP',
        'type': 'otpauth',
        'algorithm': algorithm,
        'secret': 'REMOVED',
        'digits': digits,
        'counter': counter,
        'period': period,
        'timeAdded': timeAdded
      };

  /// Creates a String representation of [OathMechanism] object.
  String toString() => jsonEncode(toJson());
}
