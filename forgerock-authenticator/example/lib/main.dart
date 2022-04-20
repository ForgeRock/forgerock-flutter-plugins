/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize SDK
  AuthenticatorProvider.initialize();

  runApp(AuthenticatorApp());
}

class AuthenticatorApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticatorProvider>(
            create: (_) => AuthenticatorProvider()..getAllAccounts()
        ),
      ],
      child: MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

}