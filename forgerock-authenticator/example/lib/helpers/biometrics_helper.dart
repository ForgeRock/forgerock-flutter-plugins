/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:forgerock_authenticator_example/widgets/alert.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

import 'diagnostic_logger.dart';

/// This Helper class is used to lock and unlock the app using Biometric authentication.
class BiometricsHelper {

  // Time allowed in milliseconds for the app to stay in background
  // before ask for Biometric authentication
  static const int pinLockMillis = 30000;

  static final LocalAuthentication _auth = LocalAuthentication();

  /// Check if device has Biometric authentication available
  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      DiagnosticLogger.severe('Error checking biometrics available on the device', e);
      return false;
    }
  }

  /// Perform Biometric authentication
  static Future<bool> authenticate({BuildContext context}) async {
    try {
      if(context == null) {
        return false;
      }

      final bool didAuthenticate = await _auth.authenticate(
        useErrorDialogs: true,
        stickyAuth: true,
        localizedReason: AppLocalizations.of(context).unLockAppLocalizedReason,
      );
      if (didAuthenticate) {
        DiagnosticLogger.fine('Successful authenticated using biometrics');
      }
      await SettingsProvider.setBackgroundedTime(0);
      await SettingsProvider.setLastKnownState(AppLifecycleState.resumed.index);
      return didAuthenticate;
    } on PlatformException catch (e) {
      DiagnosticLogger.severe('Error authenticating using biometrics', e);
      if (e.code == auth_error.notAvailable) {
        alert(context, AppLocalizations.of(context).errorTitle, AppLocalizations.of(context).unLockAppErrorRemovedLock);
      } else {
        alert(context, AppLocalizations.of(context).errorTitle, e.message);
      }
      return false;
    }
  }

  /// Check if authentication is required
  static Future<bool> isAuthenticationRequired() async {
    final int previousState = await SettingsProvider.getLastKnownState();
    if(previousState != null &&
        AppLifecycleState.values[previousState] == AppLifecycleState.resumed) {
      return false;
    } else if (await SettingsProvider.isLockEnabled()) {
      final int bgTime = await SettingsProvider.getBackgroundedTime();
      final int allowedBackgroundTime = bgTime + pinLockMillis;
      final bool previousStateIsInactive = previousState != null &&
          AppLifecycleState.values[previousState] == AppLifecycleState.inactive;
      final bool shouldPromptAuthentication = previousStateIsInactive &&
          (DateTime
              .now()
              .millisecondsSinceEpoch > allowedBackgroundTime);
      return shouldPromptAuthentication;
    } else {
      return false;
    }
  }

  /// Check if last state is Inactive
  static Future<bool> isPreviousStateInactive() async {
    final int previousState = await SettingsProvider.getLastKnownState();
    final bool previousStateIsInactive = previousState != null &&
        AppLifecycleState.values[previousState] == AppLifecycleState.inactive;
    return previousStateIsInactive;
  }

  /// App is resumed, update state
  static Future<void> onAppResumed() async {
    await SettingsProvider.setLastKnownState(AppLifecycleState.resumed.index);
    await SettingsProvider.setBackgroundedTime(0);
  }

  /// App is inactive, update last known state and set time it entered in background
  static Future<void> onAppInactive() async {
    await SettingsProvider.setLastKnownState(AppLifecycleState.inactive.index);
    await SettingsProvider.setBackgroundedTime(DateTime
        .now()
        .millisecondsSinceEpoch);
  }

  /// App is paused, update state
  static Future<void> onAppPaused() async {
    await SettingsProvider.setLastKnownState(AppLifecycleState.paused.index);
  }

}