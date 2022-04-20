/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:mockito/mockito.dart';

class MockSettingsProvider extends Mock implements SettingsProvider {

  bool _visibility = true;
  bool _lock = false;
  bool _synchronization = true;
  bool _disableScreenshot = false;
  final bool _introDone = true;
  bool _copyCode = true;
  bool _diagnosticLogging = true;


  @override
  bool get visibility => _visibility;

  @override
  Future<void> toggleVisibility(){
    _visibility = !_visibility;
    notifyListeners();
  }

  @override
  bool get lock => _lock;

  @override
  void toggleLock(){
    _lock = !_lock;
    notifyListeners();
  }

  @override
  bool get synchronization => _synchronization;

  @override
  void toggleSynchronization(){
    _synchronization = !_synchronization;
    notifyListeners();
  }

  @override
  bool get disableScreenshot => _disableScreenshot;

  @override
  void toggleDisableScreenshot(){
    _disableScreenshot = !_disableScreenshot;
    notifyListeners();
  }

  @override
  bool get introDone => _introDone;

  @override
  bool get copyCode => _copyCode;

  @override
  void toggleCopyCode(){
    _copyCode = !_copyCode;
    notifyListeners();
  }

  @override
  bool get diagnosticLogging => _diagnosticLogging;

  @override
  void toggleDiagnosticLogging(){
    _diagnosticLogging = !_diagnosticLogging;
    notifyListeners();
  }
}

MockSettingsProvider createMockSettingsProvider() {
  final MockSettingsProvider settings = MockSettingsProvider();

  return settings;
}