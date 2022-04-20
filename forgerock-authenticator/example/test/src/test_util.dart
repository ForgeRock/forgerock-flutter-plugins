/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:provider/provider.dart';

import 'mock_http_client.dart';

Future<void> eventFiring(WidgetTester tester) async {
  await tester.pump(Duration.zero);
}

Future<void> pumpForSeconds(WidgetTester tester, int seconds) async {
  bool timerDone = false;
  Timer(Duration(seconds: seconds), () => timerDone = true);
  while (timerDone != true) {
    await tester.pump();
  }
}

Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
      Duration timeout = const Duration(seconds: 300),
    }) async {
  debugPrint('===> Start pumpUntilFound $finder');
  final Stopwatch stopwatch = Stopwatch();
  stopwatch.start();
  bool timerDone = false;
  final Timer timer = Timer(timeout, () => throw TimeoutException('Pump until has timed out: ${timeout.inSeconds}'));
  while (timerDone != true) {
    await tester.pump();

    final bool found = tester.any(finder);
    if (found) {
      stopwatch.stop();
      debugPrint('===> Found element $finder');
      debugPrint('===> pumpUntilFound succeeded... It took ${stopwatch.elapsedMilliseconds} milliseconds to finish...');
      timerDone = true;
    }
  }

  timer.cancel();
}

Future<bool> scrollDownUntilFound(
    WidgetTester tester,
    Finder finder,
    int scrollAttempts,
    {Offset moveByOffset = const Offset(0, -100),
    Duration durationBetweenScrolls = const Duration(milliseconds: 500)}) async {

  debugPrint('===> Start scrollDownUntilFound :: $finder');
  bool found = false;
  int scrollCounter = 0;

  for (int i = 0; i < scrollAttempts; i++) {
    final TestGesture gesture = await tester.startGesture(const Offset(100, 300));
    await gesture.moveBy(moveByOffset);
    await tester.pump();
    await Future<void>.delayed(durationBetweenScrolls, () {});
    scrollCounter++;

    if (tester.any(finder)) {
      debugPrint('===> Found element: $finder');
      found = true;
      break;
    }
  }

  debugPrint('===> Finish scrollDownUntilFound: Result => $found');
  debugPrint('===> scrollDownUntilFound finished after $scrollCounter scrooll attempts...');
  return found;
}

Widget createMaterialWidgetForTesting({Widget child}){
  return mockNetworkImagesFor(() => MaterialApp(
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      AppLocalizations.delegate
    ],
    supportedLocales: const <Locale>[
      Locale('en', ''), // English, no country code
    ],
    home: Scaffold(body: child),
  ));
}

Widget createWidgetForTestingWithSettingsProvider({Widget child, SettingsProvider provider}){
  return MultiProvider(
      providers: <ChangeNotifierProvider<SettingsProvider>>[
        ChangeNotifierProvider<SettingsProvider>(create: (_) => provider),
      ],
      child: mockNetworkImagesFor(() => MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate
        ],
        supportedLocales: const <Locale>[
          Locale('en', ''), // English, no country code
        ],
        home: Scaffold(body: child),
      ))
  );
}

Widget createWidgetForTestingWithAuthenticatorProvider({Widget child, AuthenticatorProvider provider}){
  return MultiProvider(
      providers: <ChangeNotifierProvider<AuthenticatorProvider>>[
        ChangeNotifierProvider<AuthenticatorProvider>(create: (_) => provider),
      ],
      child: mockNetworkImagesFor(() => MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate
        ],
        supportedLocales: const <Locale>[
          Locale('en', ''), // English, no country code
        ],
        home: Scaffold(body: child),
      ))
  );
}

Widget createWidgetForTestingWithProviders({Widget child, AuthenticatorProvider authenticatorProvider,
  SettingsProvider settingsProvider}){
  return MultiProvider(
      providers: <ChangeNotifierProvider<dynamic>>[
        ChangeNotifierProvider<AuthenticatorProvider>(create: (_) => authenticatorProvider),
        ChangeNotifierProvider<SettingsProvider>(create: (_) => settingsProvider)
      ],
      child: mockNetworkImagesFor(() => MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate
        ],
        supportedLocales: const <Locale>[
          Locale('en', ''), // English, no country code
        ],
        home: Scaffold(body: child),
      ))
  );

}

