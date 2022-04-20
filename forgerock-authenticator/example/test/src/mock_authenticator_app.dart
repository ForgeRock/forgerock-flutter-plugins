/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:forgerock_authenticator_example/screens/home_screen.dart';
import 'package:provider/provider.dart';

import 'mock_http_client.dart';

Widget mockAuthenticatorApp(AuthenticatorProvider authenticatorProvider, SettingsProvider settingsProvider, [bool startSDK])  {
  if (startSDK != null && startSDK) {
    AuthenticatorProvider.initialize();
  }

  return MultiProvider(
        providers: <ChangeNotifierProvider<dynamic>>[
          ChangeNotifierProvider<AuthenticatorProvider>(create: (_) => authenticatorProvider),
          ChangeNotifierProvider<SettingsProvider>(create: (_) => settingsProvider),
        ],
        child: mockNetworkImagesFor(() => const MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizations.delegate
          ],
          supportedLocales: <Locale>[
            Locale('en', ''), // English, no country code
          ],
          home: HomeScreen(),
        )),
      );
}
