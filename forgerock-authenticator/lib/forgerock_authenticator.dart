/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'models/account.dart';
import 'models/mechanism.dart';
import 'models/oath_token_code.dart';
import 'models/push_mechanism.dart';
import 'models/push_notification.dart';

/// The [ForgerockAuthenticator] entry point. Represents the Authenticator module of the ForgeRock
/// Mobile SDK. It is the front facing class where the methods available in the SDK can be
/// found and utilized.
class ForgerockAuthenticator {

  static const MethodChannel _channel = MethodChannel('forgerock_authenticator');
  static const EventChannel _eventChannel = EventChannel('forgerock_authenticator/events');

  static const AccountParsingException = 'ACCOUNT_PARSING_EXCEPTION';
  static const AuthenticatorException = 'AUTHENTICATOR_EXCEPTION';
  static const CreateMechanismException = 'CREATE_MECHANISM_EXCEPTION';
  static const DuplicateMechanismException = 'DUPLICATE_MECHANISM_EXCEPTION';
  static const HandleNotificationException = 'HANDLE_NOTIFICATION_EXCEPTION';
  static const InvalidQRcodeException = 'INVALID_QRCODE_EXCEPTION';
  static const InvalidNotificationException = 'INVALID_NOTIFICATION_EXCEPTION';
  static const OathMechanismException = 'OATH_MECHANISM_EXCEPTION';
  static const PlatformArgumnetException = 'PLATAFORM_ARGUMENT_EXCEPTION';
  static const PushRegistrationException = 'PUSH_REGISTRATION_EXCEPTION';

  //
  // Authenticator SDK methods
  //

  /// Initialize the authenticator SDK
  static Future start() async {
    try {
      await _channel.invokeMethod('start');
    } on PlatformException catch (ex) {
      throw ex;
    }
  }

  /// Create a [Mechanism] using the URL extracted from the QRCode. This URL contains information about
  /// the mechanism itself, as the account. After validation the mechanism will be persisted and returned
  static Future<Mechanism> createMechanismFromUri(String uri) async {
    try {
      var params = <String, dynamic>{
        'uri': uri,
      };
      var json = await _channel.invokeMethod('createMechanismFromUri', params);
      return Mechanism.fromJson(_getPlatformData(json), null);
    } on PlatformException catch (ex) {
      throw ex;
    }
  }

  /// Get all accounts stored in the system. Returns `null` if no [Account] could be found.
  /// This method also retrieves the [Mechanism] objects associated with the accounts.
  static Future<List<Account>> getAllAccounts() async {
    try {
      List? list = await _channel.invokeMethod('getAllAccounts');
      if(list != null && list.isNotEmpty) {
        List<Account> accounts = [];
        for(final element in list) {
          accounts.add(Account.fromJson(_getPlatformData(element)));
        }
        return accounts;
      } else {
        return List.empty();
      }

    } on PlatformException catch (ex) {
      throw ex;
    }
  }

  /// Update the [Account] object. Returns `false` if it could not be found or updated.
  static Future<bool?> updateAccount(String accountJson) async {
    var params = <String, dynamic>{
      'accountJson': accountJson,
    };
    return await _channel.invokeMethod('updateAccount', params);
  }

  /// Remove from the storage system the [Account] which id was passed in, all [Mechanism] objects
  /// and any [PushNotification] objects associated with it.
  static Future<bool?> removeAccount(String accountId) async {
    var params = <String, dynamic>{
      'accountId': accountId,
    };
    return await _channel.invokeMethod('removeAccount', params);
  }

  /// Remove from the storage the [Mechanism] which id was passed in and any [PushNotification] objects
  /// associated with it.
  static Future<bool?> removeMechanism(String mechanismUID) async {
    var params = <String, dynamic>{
      'mechanismUID': mechanismUID,
    };
    return await _channel.invokeMethod('removeMechanism', params);
  }

  /// Generates a new set of codes for the [OathMechanism] which id was passed in.
  /// Returns an [OathTokenCode] object that contains the currently active token code.
  static Future<OathTokenCode?> getOathTokenCode(String? mechanismId) async {
    var params = <String, dynamic>{
      'mechanismId': mechanismId,
    };
    var data = await _channel.invokeMethod('getOathTokenCode', params);
    return OathTokenCode.fromJson(_getPlatformData(data));
  }

  /// Get the [PushNotification] object with its id. Identifier of PushNotification object is "<mechanismUUID>-<timeAdded>"
  /// Returns `null` if the notification could not be found.
  static Future<PushNotification?> getNotification(String notificationId) async {
    var params = <String, dynamic>{
      'notificationId': notificationId,
    };
    var notification = await _channel.invokeMethod('getNotification', params);
    if(notification != null) {
      return PushNotification.fromJson(_getPlatformData(notification));
    } else {
      return null;
    }
  }

  /// Receives an APNS or FCM remote message and covert into a [PushNotification] object,
  /// which allows accept or deny Push Authentication requests.
  static Future<PushNotification?> handleMessageWithPayload(Map<String, dynamic> userInfo) async {
    var params = <String, dynamic>{
      'userInfo': userInfo,
    };
    var json = await _channel.invokeMethod('handleMessageWithPayload', params);
    if(json != null) {
      return PushNotification.fromJson(_getPlatformData(json));
    } else {
      return null;
    }
  }

  /// Respond an authentication request from a given [PushNotification] received from OpenAM.
  static Future<bool?> performPushAuthentication(PushNotification pushNotification, bool accept) async {
    String notificationId = pushNotification.id;
    var params = <String, dynamic>{
      'notificationId': notificationId,
      'accept': accept,
    };
    return await _channel.invokeMethod('performPushAuthentication', params);
  }

  /// Get all of the notifications that belong to an [Account] object.
  /// Returns `null` if no [PushNotification] could be found or the accountId is invalid.
  static Future<List<PushNotification>> getAllNotificationsByAccountId(String accountId) async {
    var params = <String, dynamic>{
      'accountId': accountId,
    };
    try {
      List? list = await _channel.invokeMethod('getAllNotifications', params);
      if(list != null && list.isNotEmpty) {
        List<PushNotification> notifications = [];
        for(final element in list) {
          notifications.add(PushNotification.fromJson(_getPlatformData(element)));
        }
        return notifications;
      } else {
        return List.empty();
      }

    } on PlatformException catch (ex) {
      throw ex;
    }
  }

  /// Get the number of non-expired notifications across all mechanisms.
  static Future<int> getPendingNotificationsCount() async {
    final int count = await _channel.invokeMethod('getPendingNotificationsCount');
    return count;
  }

  /// Get single list of notifications across all mechanisms.
  /// Returns `null` if no [PushNotification] could be found.
  static Future<List<PushNotification>> getAllNotifications() async {
    try {
      var mechanismMap = await _channel.invokeMethod('getAllMechanismsGroupByUID');
      List? list = await _channel.invokeMethod('getAllNotifications');
      if(list != null && list.isNotEmpty) {
        List<PushNotification> notifications = [];
        for(final element in list) {
          PushNotification pushNotification = PushNotification.fromJson(_getPlatformData(element));
          if(mechanismMap.isNotEmpty) {
            final mechanismJson = mechanismMap[pushNotification.mechanismUID];
            if(mechanismJson != null) {
              final pushMechanism = Mechanism.fromJson(_getPlatformData(mechanismJson));
              pushNotification.setMechanism(pushMechanism as PushMechanism?);
              notifications.add(pushNotification);
            }
          }
        }
        return notifications;
      } else {
        return List.empty();
      }

    } on PlatformException catch (ex) {
      throw ex;
    }
  }


  //
  // App helper methods
  //

  /// Indicates if the app was ever launched before.
  static Future<bool?> hasAlreadyLaunched() =>  _channel.invokeMethod<bool?>('hasAlreadyLaunched');

  /// Disable screenshoot capture on Android devices.
  static Future<bool?> disableScreenshot() async {
    try {
      return await _channel.invokeMethod('disableScreenshot');
    } on PlatformException catch (ex) {
      throw ex;
    }
  }

  /// Enable screenshoot capture on Android devices.
  static Future<bool?> enableScreenshot() async {
    try {
      return await _channel.invokeMethod('enableScreenshot');
    } on PlatformException catch (ex) {
      throw ex;
    }
  }

  /// Removed all data from the secured storage.
  static Future removeAllData() async {
    return await _channel.invokeMethod('removeAllData');
  }

  static _getPlatformData(element) {
    if(element == null) {
      return null;
    } else if(element is String) {
      return jsonDecode(element);
    } else {
      return Map<String, dynamic>.from(element);
    }
  }


  //
  // Deep Link methods
  //

  static Future<String?> getInitialLink() =>  _channel.invokeMethod<String?>('getInitialLink');

  static late final Stream<String?> linkStream = _eventChannel
      .receiveBroadcastStream()
      .map<String?>((dynamic link) => link as String?);

  static Future<Uri?> getInitialUri() async {
    final link = await getInitialLink();
    if (link == null) return null;
    return Uri.parse(link);
  }

  static late final uriLinkStream = linkStream.transform<Uri?>(
    StreamTransformer<String?, Uri?>.fromHandlers(
      handleData: (String? link, EventSink<Uri?> sink) {
        if (link == null) {
          sink.add(null);
        } else {
          sink.add(Uri.parse(link));
        }
      },
    ),
  );

}
