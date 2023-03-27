/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The [ForgerockPushConnector] fires notifications whenever an APNS/FCM token
/// are generated and a remote message is received.
class ForgerockPushConnector {
  final MethodChannel _channel = const MethodChannel('forgerock_authenticator');

  /// Last pending push message.
  /// initially nil
  late ValueNotifier<dynamic> _pendingNotification;

  /// Value of registered token
  /// initially nil
  late ValueNotifier<String?> _token;

  ValueNotifier get pendingNotification {
    return _pendingNotification;
  }

  ValueNotifier get token {
    return _token;
  }

  ForgerockPushConnector() {
    _channel.setMethodCallHandler(_handleMethod);
    _pendingNotification = ValueNotifier<dynamic>(null);
    _token = ValueNotifier<String?>(null);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onToken':
        print('onToken: ${call.arguments}');
        _token.value = call.arguments;
        return null;
      case 'onMessage':
        print('onMessage: ${call.arguments}');
        _pendingNotification.value = call.arguments;
        return null;
      default:
        throw UnsupportedError('Unrecognized JSON message');
    }
  }
}
