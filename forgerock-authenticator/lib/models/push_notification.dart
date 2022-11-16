/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'push_mechanism.dart';
import 'push_type.dart';

/// PushNotification is a model class which represents a message that was received from an external
/// source.
class PushNotification {
  String? mechanismUID;
  String? messageId;
  String? challenge;
  String? amlbCookie;
  String? customPayload;
  String? message;
  String? contextInfo;
  String? numbersChallenge;
  int? timeAdded;
  int? timeExpired;
  int? ttl;
  bool? approved;
  bool? pending;
  PushType? pushType;
  PushMechanism? _pushMechanism;

  /// Creates the PushNotification object with given data.
  PushNotification(
      this.mechanismUID,
      this.messageId,
      this.challenge,
      this.amlbCookie,
      this.customPayload,
      this.message,
      this.contextInfo,
      this.numbersChallenge,
      this.timeAdded,
      this.timeExpired,
      this.ttl,
      this.approved,
      this.pending,
      this.pushType);

  /// Deserializes the specified JSON into an object of the [PushNotification] object.
  factory PushNotification.fromJson(Map<String, dynamic>? json) {
    String pushType =
        json?['pushType'] == null ? PushType.DEFAULT.value : json?['pushType'];
    return PushNotification(
        json?['mechanismUID'],
        json?['messageId'],
        json?['challenge'],
        json?['amlbCookie'],
        json?['customPayload'],
        json?['message'],
        json?['contextInfo'],
        json?['numbersChallenge'],
        json?['timeAdded'],
        json?['timeExpired'],
        json?['ttl'],
        json?['approved'],
        json?['pending'],
        pushType.parsePushType());
  }

  /// Sets the mechanism object associated with the notification.
  void setMechanism(PushMechanism? mechanism) {
    _pushMechanism = mechanism;
  }

  /// Gets the mechanism object associated with the notification.
  PushMechanism? getMechanism() {
    return _pushMechanism;
  }

  /// Gets the challenge numbers associated with the notification.
  /// If no challenge numbers are available, return an empty list.
  List<String>? getNumbersChallenge() {
    if (numbersChallenge == null) {
      return List.empty();
    }
    return numbersChallenge?.split(',');
  }

  /// Gets the contextual information associated with the notification.
  /// If no context information is available, return an empty Map.
  Map<String, dynamic>? getContextInfo() {
    if (contextInfo == null) {
      return Map();
    }
    return jsonDecode(contextInfo!);
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
        'customPayload': customPayload,
        'numbersChallenge': numbersChallenge,
        'contextInfo': contextInfo,
        'pushType': pushType?.value,
      };

  /// Creates a String representation of [PushNotification] object.
  String toString() => jsonEncode(toJson());

  /// Gets the Unique identifier for PushNotification object associated with the mechanism
  String get id {
    return '$mechanismUID-$timeAdded';
  }
}
