/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forgerock_authenticator/forgerock_authenticator.dart';

import 'diagnostic_logger.dart';

class DeepLinkHelper {

  factory DeepLinkHelper() {
    return _instance;
  }

  DeepLinkHelper._internal() {
    WidgetsFlutterBinding.ensureInitialized();
    _handleIncomingLinks();
    _handleInitialUri();
  }

  static final DeepLinkHelper _instance = DeepLinkHelper._internal();

  String get initialUrl => _initialUri?.toString(); //_initialUri != null ? _initialUri.toString() : null;
  String get latestUrl => _latestUri?.toString(); //_latestUri != null ? _latestUri.toString() : null;
  Object get error => _err;

  Uri _initialUri;
  Uri _latestUri;
  Object _err;
  bool _initialUriIsHandled = false;

  /// Handle incoming links - the ones that the app will receive from the OS
  /// while already started.
  void _handleIncomingLinks() {
    ForgerockAuthenticator.uriLinkStream.listen((Uri uri) {
        DiagnosticLogger.fine('Got URI via deeplink: ${uri.toString().substring(0, 10)}');
        _latestUri = uri;
        _err = null;
      }, onError: (Object err) {
        DiagnosticLogger.severe('Got error on processing deeplink', err);
        _latestUri = null;
        if (err is FormatException) {
          _err = err;
        } else {
          _err = null;
        }
      });
  }

  /// Handle the initial Uri - the one the app was started with
  Future<void> _handleInitialUri() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      DiagnosticLogger.fine('Checking for launch with URI...');
      try {
        final Uri uri = await ForgerockAuthenticator.getInitialUri();
        if (uri == null) {
          DiagnosticLogger.fine('No initial URI');
        } else {
          DiagnosticLogger.fine('Got initial URI: ${uri.toString().substring(0, 10)}');
        }
        _initialUri = uri;
      } on PlatformException catch (platformError) {
        // Platform messages may fail but we ignore the exception
        DiagnosticLogger.severe('Platform failed to get initial URI. This can be ignored.', platformError);
      } on FormatException catch (formatError) {
        DiagnosticLogger.severe('Malformed initial URI', formatError);
        _err = formatError;
      }
    }
  }

  void clearLatestUri() {
    _latestUri = null;
  }
}