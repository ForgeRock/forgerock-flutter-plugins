/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'account.dart';
import 'push_mechanism.dart';
import 'oath_mechanism.dart';

class Mechanism {
  String? id;
  String? mechanismUID;
  String? issuer;
  String? accountName;
  String? type;
  String? _secret;
  int? timeAdded;
  Account? account;

  static const String PUSH = "pushauth";
  static const String OATH = "otpauth";

  /// The Mechanism model represents the two-factor way used for authentication.
  /// Encapsulates the related settings, as well as an owning Account.
  Mechanism(this.id, this.mechanismUID, this.issuer, this.accountName,
      this.type, this._secret, this.timeAdded, [this.account]);

  /// Deserializes the specified Json into an object of the [Mechanism] object.
  factory Mechanism.fromJson(Map<String, dynamic> json, [Account? account]) {
    if (json['type'] == PUSH) {
      return PushMechanism.fromJson(json, account);
    } else if (json['type'] == OATH) {
      return OathMechanism.fromJson(json, account);
    } else {
      return Mechanism(json['id'],json['mechanismUID'],json['issuer'],
          json['accountName'],json['type'],json['secret'],json['timeAdded'],
          account
      );
    }
  }

  /// Creates a JSON string representation of [Mechanism] object.
  Map<String, dynamic> toJson() => {
      'id': id,
      'issuer': issuer,
      'accountName': accountName,
      'mechanismUID': mechanismUID,
      'type': type,
      'secret': _secret?.replaceRange(0, null, 'REMOVED')
  };

  /// Gets the account identification associated with the mechanism.
  String getAccountId() {
    return "$issuer-$accountName";
  }

  /// Sets the [Account] object associated with the mechanism.
  void setAccount(Account account) {
    this.account = account;
  }

  /// Gets the [Account] object associated with the mechanism.
  Account? getAccount() {
    return this.account;
  }

}

