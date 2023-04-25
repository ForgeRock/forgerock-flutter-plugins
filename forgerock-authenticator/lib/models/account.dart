/*
 * Copyright (c) 2022-2023 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'oath_mechanism.dart';
import 'push_mechanism.dart';
import 'mechanism.dart';

/// Account model represents an identity for the user with an issuer. It is possible for a user to
/// have multiple accounts provided by a single issuer, however it is not possible to have multiple
/// accounts from with same issuer for the same account name.
class Account {
  String? id;
  String? issuer;
  String? displayIssuer;
  String? accountName;
  String? displayAccountName;
  String? imageURL;
  String? backgroundColor;
  int? timeAdded;
  String? policies;
  String? lockingPolicy;
  bool? lock;
  List<Mechanism>? mechanismList;

  /// Creates Account object with given information.
  Account(
      this.id,
      this.issuer,
      this.displayIssuer,
      this.accountName,
      this.displayAccountName,
      this.imageURL,
      this.backgroundColor,
      this.timeAdded,
      this.policies,
      this.lockingPolicy,
      this.lock,
      [this.mechanismList]);

  /// Deserializes the specified Json into an object of the [Account] object.
  /// This account object may include a list of [Mechanism]
  factory Account.fromJson(Map<String, dynamic> json) {
    Account account = Account(
        json['id'],
        json['issuer'],
        json['displayIssuer'],
        json['accountName'],
        json['displayAccountName'],
        json['imageURL'] == 'null' ? null : json['imageURL'],
        json['backgroundColor'] == 'null' ? null : json['backgroundColor'],
        json['timeAdded'],
        json['policies'] == 'null' ? null : json['policies'],
        json['lockingPolicy'] == 'null' ? null : json['lockingPolicy'],
        json['lock'] == null ? false : json['lock']
    );

    if (json['mechanismList'] != null) {
      List? toParseList;
      if (json['mechanismList'] is String) {
        toParseList = jsonDecode(json['mechanismList']);
      } else {
        toParseList = json['mechanismList'];
      }

      List<Mechanism> mechanismList = [];
      for (final element in toParseList!) {
        if (element is String) {
          mechanismList.add(Mechanism.fromJson(jsonDecode(element), account));
        } else if (element is Map<String, dynamic>) {
          mechanismList.add(Mechanism.fromJson(element, account));
        } else {
          var tmp = Map<String, dynamic>.from(element);
          mechanismList.add(Mechanism.fromJson(tmp, account));
        }
      }
      account.mechanismList = mechanismList;
    }

    return account;
  }

  /// Creates a JSON string representation of [Account] object.
  Map<String, dynamic> toJson() {
    List<String> list = [];
    if (mechanismList != null) {
      for (final element in mechanismList!) {
        list.add(jsonEncode(element.toJson()));
      }
    }
    Map<String, dynamic> jsonMap = {
      'id': id,
      'issuer': issuer,
      'displayIssuer': displayIssuer,
      'accountName': accountName,
      'displayAccountName': displayAccountName,
      'imageURL': imageURL,
      'backgroundColor': backgroundColor,
      'timeAdded': timeAdded,
      'policies': policies,
      'lockingPolicy': lockingPolicy,
      'lock': lock,
      'mechanismList': list
    };
    return jsonMap;
  }

  /// Gets the name of the IDP that issued this account.
  String? getIssuer() {
    if (this.displayIssuer != "null" &&
        this.displayIssuer != null &&
        this.displayIssuer!.isNotEmpty) {
      return this.displayIssuer;
    } else {
      return this.issuer;
    }
  }

  /// Gets the name of the account.
  String? getAccountName() {
    if (this.displayAccountName != "null" &&
        this.displayAccountName != null &&
        this.displayAccountName!.isNotEmpty) {
      return this.displayAccountName;
    } else {
      return this.accountName;
    }
  }

  /// Gets the [OathMechanism] associated with this account.
  OathMechanism? getOathMechanism() {
    if (mechanismList == null) {
      return null;
    }

    for (Mechanism mechanism in mechanismList!) {
      if (mechanism.type == Mechanism.OATH) {
        return mechanism as OathMechanism?;
      }
    }
    return null;
  }

  /// Returns true if a [OathMechanism] is associated with this account.
  bool hasOathMechanism() {
    return getOathMechanism() != null ? true : false;
  }

  /// Gets the [PushMechanism] associated with this account.
  PushMechanism? getPushMechanism() {
    if (mechanismList == null) {
      return null;
    }

    for (Mechanism mechanism in mechanismList!) {
      if (mechanism.type == Mechanism.PUSH) {
        return mechanism as PushMechanism?;
      }
    }
    return null;
  }

  /// Returns true if a [PushMechanism] is associated with this account.
  bool hasPushMechanism() {
    return getPushMechanism() != null ? true : false;
  }

  /// Returns true if this account has more the one [Mechanism].
  bool hasMultipleMechanisms() {
    return (mechanismList!.length > 1) ? true : false;
  }

  /// Creates a String representation of [Account] object.
  String toString() => jsonEncode(toJson());
}
