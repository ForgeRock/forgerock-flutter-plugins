/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'account.dart';
import 'mechanism.dart';

/// Represents an instance of a Push authentication mechanism. Associated with an [Account].
class PushMechanism extends Mechanism {
  String? registrationEndpoint;
  String? authenticationEndpoint;

  /// Creates [PushMechanism] object with given information.
  PushMechanism(
      String? id,
      String? mechanismUID,
      String? issuer,
      String? accountName,
      String? type,
      String? secret,
      String? registrationEndpoint,
      String? authenticationEndpoint,
      int? timeAdded,
      [Account? account])
      : super(id, mechanismUID, issuer, accountName, type, secret, timeAdded,
            account) {
    this.authenticationEndpoint = authenticationEndpoint;
    this.registrationEndpoint = registrationEndpoint;
  }

  /// Deserializes the specified Json into an object of the [PushMechanism] object.
  factory PushMechanism.fromJson(Map<String, dynamic> json,
      [Account? account]) {
    return PushMechanism(
        json['id'],
        json['mechanismUID'],
        json['issuer'],
        json['accountName'],
        json['type'],
        json['secret'],
        json['registrationEndpoint'],
        json['authenticationEndpoint'],
        json['timeAdded'],
        account);
  }

  /// Creates a JSON string representation of [PushMechanism] object.
  Map<String, dynamic> toJson() => {
        'id': id,
        'issuer': issuer,
        'accountName': accountName,
        'mechanismUID': mechanismUID,
        'type': 'pushauth',
        'secret': 'REMOVED',
        'authenticationEndpoint': authenticationEndpoint,
        'registrationEndpoint': null,
      };

  /// Creates a String representation of [PushMechanism] object.
  String toString() => jsonEncode(toJson());
}
