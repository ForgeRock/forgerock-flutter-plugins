/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:collection';

import 'package:flutter/foundation.dart' show FlutterError, FlutterErrorDetails, kDebugMode;
import 'package:logging/logging.dart';

class DiagnosticLogger {

  static const String activeNetworkKey = 'activeNetwork';
  static const String platformKey = 'platform';
  static const String platformVersionKey = 'platformVersion';
  static const String deviceModelKey = 'deviceModel';
  static const String deviceManufacturerKey = 'deviceManufacturer';
  static const String deviceIdKey = 'deviceId';
  static const String localeKey = 'locale';
  static const String settingsKey = 'settings';
  static const String appVersionKey = 'appVersion';
  static const String appBuildKey = 'appBuild';
  static const String isPhysicalDeviceKey = 'isPhysicalDevice';
  static const String bugReportEmailKey = 'bugReportEmail';
  static const String bugReportDescriptionKeys = 'bugReportDescription';

  static Queue<LogRecord> logs = Queue<LogRecord>();

  static void initializeLog() {
    // initialize log collector
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord record) {
      logs.addLast(record);
      while(logs.length > 50) {
        logs.removeFirst();
      }
      if (kDebugMode) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      }
    });
  }

  static void severe(Object message, [Object exception, StackTrace stackTrace]) {
    Logger.root.severe(message, exception, stackTrace);
  }

  static void fine(Object message, [Object error, StackTrace stackTrace]) {
    Logger.root.fine(message, error, stackTrace);
  }

  static void info(Object message) {
    Logger.root.info(message);
  }

  static void reportUncaughtError(FlutterErrorDetails flutterErrorDetails) {
    FlutterError.presentError(flutterErrorDetails);
  }

}
