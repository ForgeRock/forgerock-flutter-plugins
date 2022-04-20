/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:forgerock_authenticator/models/oath_token_code.dart';

/// Format the OTP code for easy recognition by the user
String formatCode(OathTokenCode oathTokenCode) {
  final String code = oathTokenCode.code;
  final int half = code.length ~/ 2;
  return '${code.substring(0, half)} ${code.substring(half, code.length)}';
}

/// Get the seconds left before the token expires
int getSecondsLeft(OathTokenCode oathTokenCode) {
  final int cur = DateTime.now().millisecondsSinceEpoch;
  final int total = oathTokenCode.until - oathTokenCode.start;
  final int state = cur - oathTokenCode.start;
  final int secondsLeft = ((total - state) ~/ 1000)+1;

  if(0 <= secondsLeft) {
    return secondsLeft;
  } else {
    return 1;
  }
}

/// Get the expiration time for the token in seconds
int getDuration(OathTokenCode oathTokenCode) {
  return (oathTokenCode.until - oathTokenCode.start) ~/ 1000;
}