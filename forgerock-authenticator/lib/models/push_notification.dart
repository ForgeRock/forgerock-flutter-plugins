/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'push_mechanism.dart';

/// PushNotification is a model class which represents a message that was received from an external
/// source.
class PushNotification {
  String? mechanismUID;
  String? messageId;
  String? challenge;
  String? amlbCookie;
  int? timeAdded;
  int? timeExpired;
  int? ttl;
  bool? approved;
  bool? pending;
  PushMechanism? _pushMechanism;

  /// Creates the PushNotification object with given data.
  PushNotification(
      this.mechanismUID,
      this.messageId,
      this.challenge,
      this.amlbCookie,
      this.timeAdded,
      this.timeExpired,
      this.ttl,
      this.approved,
      this.pending);

  /// Deserializes the specified JSON into an object of the [PushNotification] object.
  factory PushNotification.fromJson(Map<String, dynamic>? json) {
      return PushNotification(json?['mechanismUID'],json?['messageId'],json?['challenge'],
          json?['amlbCookie'],json?['timeAdded'],json?['timeExpired'],json?['ttl'],
          json?['approved'],json?['pending']
      );
  }

  /// Sets the mechanism object associated with the notification.
  void setMechanism(PushMechanism? mechanism) {
    _pushMechanism = mechanism;
  }

  /// Gets the mechanism object associated with the notification.
  PushMechanism? getMechanism() {
    return _pushMechanism;
  }

  /// Determine if the notification has expired.
  bool isExpired() {
    var now = DateTime.now();
    var expiredDate = DateTime.fromMillisecondsSinceEpoch(timeExpired!);
    return expiredDate.isBefore(now);
  }

  /// Creates a JSON string representation of [PushNotification] object.
  Map<String, dynamic> toJson() => {
    'id': '$mechanismUID-$timeAdded',
    'mechanismUID': mechanismUID,
    'messageId': messageId,
    'challenge': challenge,
    'amlbCookie': amlbCookie,
    'timeAdded': timeAdded,
    'timeExpired': timeExpired,
    'ttl': ttl,
    'approved': approved,
    'pending': pending,
  };

  /// Creates a String representation of [PushNotification] object.
  String toString() => jsonEncode(toJson());

  /// Gets the Unique identifier for PushNotification object associated with the mechanism
  String get id {
    return '$mechanismUID-$timeAdded';
  }

}