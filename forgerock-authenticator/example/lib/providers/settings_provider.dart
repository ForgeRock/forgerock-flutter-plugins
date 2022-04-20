/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator_example/helpers/diagnostic_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This class manages the app settings and provide easily access to make changes
class SettingsProvider extends ChangeNotifier {

  SettingsProvider() {
    _loadPreferences();
  }

  static Future<SettingsProvider> initialize() async {
    return SettingsProvider();
  }

  static const String visibilityKey = 'visibility';
  static const String lockKey = 'lock';
  static const String synchronizationKey = 'synchronization';
  static const String storageVersionKey = 'storageVersion';
  static const String orderKey = 'order';
  static const String screenshotKey = 'screenshot';
  static const String introKey = 'intro';
  static const String copyCodeKey = 'copyCode';
  static const String diagnosticLoggingKey = 'diagnosticLogging';
  static const String lastKnownStateKey = 'lastKnownState';
  static const String backgroundedTimeKey = 'backgroundedTime';

  SharedPreferences _sharedPreferences;
  bool _visibility;
  bool _lock;
  bool _synchronization;
  bool _disableScreenshot;
  bool _introDone;
  bool _copyCode;
  bool _diagnosticLogging;
  int _storageVersion;
  int _lastKnownState;
  int _backgroundedTime;
  List<String> _order;

  bool get visibility => _visibility;
  bool get lock => _lock;
  bool get synchronization => _synchronization;
  bool get disableScreenshot => _disableScreenshot;
  bool get introDone => _introDone;
  bool get copyCode => _copyCode;
  bool get diagnosticLogging => _diagnosticLogging;
  int get storageVersion => _storageVersion;
  int get lastKnownState => _lastKnownState;
  int get backgroundedTime => _backgroundedTime;
  List<String> get order => _order;

  Future<void> toggleVisibility() async {
    _visibility = !_visibility;
    _sharedPreferences.setBool(visibilityKey, _visibility);
    notifyListeners();
  }

  void toggleLock(){
    _lock = !_lock;
    _sharedPreferences.setBool(lockKey, _lock);
    notifyListeners();
  }

  void toggleSynchronization(){
    _synchronization = !_synchronization;
    _sharedPreferences.setBool(synchronizationKey, _synchronization);
    notifyListeners();
  }

  void toggleDisableScreenshot(){
    _disableScreenshot = !_disableScreenshot;
    _sharedPreferences.setBool(screenshotKey, _disableScreenshot);
    notifyListeners();
  }

  void toggleCopyCode(){
    _copyCode = !_copyCode;
    _sharedPreferences.setBool(copyCodeKey, _copyCode);
    notifyListeners();
  }

  void toggleDiagnosticLogging(){
    _diagnosticLogging = !_diagnosticLogging;
    _sharedPreferences.setBool(diagnosticLoggingKey, _diagnosticLogging);
    notifyListeners();
  }

  Future<void> _initPreferences() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadPreferences() async {
    await _initPreferences();
    _visibility = _sharedPreferences.getBool(visibilityKey) ?? true;
    _lock = _sharedPreferences.getBool(lockKey) ?? false;
    _synchronization = _sharedPreferences.getBool(synchronizationKey) ?? false;
    _disableScreenshot = _sharedPreferences.getBool(screenshotKey) ?? true;
    _introDone = _sharedPreferences.getBool(introKey) ?? false;
    _copyCode = _sharedPreferences.getBool(copyCodeKey) ?? true;
    _diagnosticLogging = _sharedPreferences.getBool(diagnosticLoggingKey) ?? true;
    _storageVersion = _sharedPreferences.getInt(storageVersionKey) ?? 0;
    _lastKnownState = _sharedPreferences.getInt(lastKnownStateKey) ?? 0;
    _backgroundedTime = _sharedPreferences.getInt(backgroundedTimeKey) ?? 0;
    _order = _sharedPreferences.getStringList(orderKey) ?? <String>[];
    notifyListeners();
  }

  Future<void> savePreferences() async {
    await _initPreferences();
    _sharedPreferences.setBool(visibilityKey, _visibility);
    _sharedPreferences.setBool(lockKey, _lock);
    _sharedPreferences.setBool(synchronizationKey, _synchronization);
    _sharedPreferences.setBool(screenshotKey, _disableScreenshot);
    _sharedPreferences.setBool(introKey, _introDone);
    _sharedPreferences.setBool(copyCodeKey, _copyCode);
    _sharedPreferences.setBool(diagnosticLoggingKey, _diagnosticLogging);
    _sharedPreferences.setInt(storageVersionKey, _storageVersion);
    _sharedPreferences.setInt(lastKnownStateKey, _lastKnownState);
    _sharedPreferences.setInt(backgroundedTimeKey, _backgroundedTime);
    _sharedPreferences.setStringList(orderKey, _order);
  }

  static Future<bool> isLockEnabled() async {
    DiagnosticLogger.fine('Checking if app is locked');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(lockKey) ?? false;
  }

  static Future<bool> isScreenshotDisabled() async {
    DiagnosticLogger.fine('Checking if screenshot is disabled');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(screenshotKey) ?? true;
  }

  static Future<bool> isIntroDone() async {
    DiagnosticLogger.fine('Checking if intro screen was displayed');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(introKey) ?? false;
  }

  static Future<bool> isDiagnosticLoggingEnabled() async {
    DiagnosticLogger.fine('Checking if diagnostic logging is enabled');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(diagnosticLoggingKey) ?? true;
  }

  static Future<int> getLastKnownState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(lastKnownStateKey) ?? 0;
  }

  static Future<void> setLastKnownState(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(lastKnownStateKey, value);
  }

  static Future<int> getBackgroundedTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(backgroundedTimeKey) ?? 0;
  }

  static Future<void> setBackgroundedTime(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(backgroundedTimeKey, value);
  }

  static Future<int> getStorageVersion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(storageVersionKey) ?? 0;
  }

  static Future<void> setStorageVersion(int version) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(storageVersionKey, version);
  }

  static Future<List<String>> getAccountsOrder() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(orderKey) ?? <String>[];
  }

  static Future<void> saveAccountsOrder(List<String> list) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(orderKey, list);
  }

  static Future<void> setIntroDone(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(introKey, value);
  }

  static Future<String> toJson() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> jsonMap = <String, dynamic> {
      visibilityKey : prefs.getBool(lockKey) ?? false,
      lockKey: prefs.getBool(lockKey) ?? false,
      synchronizationKey: prefs.getBool(synchronizationKey) ?? false,
      screenshotKey: prefs.getBool(screenshotKey) ?? true,
      introKey: prefs.getBool(introKey) ?? false,
      copyCodeKey: prefs.getBool(copyCodeKey) ?? true,
      diagnosticLoggingKey: prefs.getBool(diagnosticLoggingKey) ?? true,
      lastKnownStateKey: prefs.getInt(lastKnownStateKey) ?? 0,
      backgroundedTimeKey: prefs.getInt(backgroundedTimeKey) ?? 0,
      storageVersionKey: prefs.getInt(storageVersionKey) ?? 0,
      orderKey: prefs.getStringList(orderKey) ?? <String>[],
    };
    return jsonEncode(jsonMap);
  }
}




