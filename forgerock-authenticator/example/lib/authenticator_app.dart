/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator_example/helpers/deep_link_helper.dart';
import 'package:forgerock_authenticator_example/screens/loading/loading_screen.dart';
import 'package:forgerock_authenticator_example/widgets/localized_app.dart';
import 'package:provider/provider.dart';

import '/providers/authenticator_provider.dart';
import '/providers/settings_provider.dart';

class AuthenticatorApp extends StatelessWidget {

  AuthenticatorApp({Key key}) : super(key: key);

  final AuthenticatorProvider _authenticatorProvider = AuthenticatorProvider();
  final SettingsProvider _settingsProvider = SettingsProvider();

  @override
  Widget build(BuildContext context) {
    // initialize deep link helper
    DeepLinkHelper();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticatorProvider>(create: (_) => _authenticatorProvider),
        ChangeNotifierProvider<SettingsProvider>(create: (_) => _settingsProvider),
      ],
      child: const LocalizedApp(
        child: LoadingScreen()
      ),
    );
  }

}
