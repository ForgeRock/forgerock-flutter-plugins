/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator_example/authenticator_app.dart';

import 'helpers/diagnostic_logger.dart';
import 'providers/authenticator_provider.dart';
import 'providers/settings_provider.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // initialize all dependencies and setup app based on settings
    await _initializeDependenciesAndSetup();

    // pass all uncaught errors from the framework to Crashlytics
    FlutterError.onError = DiagnosticLogger.reportUncaughtError;

    // launch app
    runApp(AuthenticatorApp());
  }, (Object error, StackTrace stackTrace) {
    // handle asynchronous errors
    DiagnosticLogger.severe('Asynchronous error', error, stackTrace);
  });
}

Future<void> _initializeDependenciesAndSetup() async {
  // initialize logging
  DiagnosticLogger.initializeLog();

  // initialize Authenticator SDK
  AuthenticatorProvider.initialize();

  // check if screenshot is disabled
  if(Platform.isAndroid) {
    if (await SettingsProvider.isScreenshotDisabled()) {
      AuthenticatorProvider.disableScreenshot();
    }
  }
}
