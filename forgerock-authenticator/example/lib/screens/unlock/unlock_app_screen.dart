/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator_example/helpers/biometrics_helper.dart';
import 'package:forgerock_authenticator_example/helpers/diagnostic_logger.dart';
import 'package:forgerock_authenticator_example/screens/home_screen.dart';
import 'package:forgerock_authenticator_example/screens/unlock/gradient_background.dart';
import 'package:forgerock_authenticator_example/widgets/no_animation_page_route.dart';

class UnlockApp extends StatefulWidget {

  const UnlockApp({Key key}) : super(key: key);

  @override
  State<UnlockApp> createState() => UnlockAppState();
}

class UnlockAppState extends State<UnlockApp> {

  bool _authenticated;

  @override
  void initState() {
    super.initState();
    DiagnosticLogger.fine('Initializing UnlockApp...');
    _loadWidget();
  }

  void _loadWidget() {
    _authenticated = false;
    DiagnosticLogger.fine('User authenticated: $_authenticated');
    Future<void>.delayed(const Duration(milliseconds: 500), _authenticate);
  }

  Future<void> _authenticate() async {
    DiagnosticLogger.fine('Starting Biometric authentication...');
    _authenticated = await BiometricsHelper.authenticate(context: context);
    DiagnosticLogger.fine('Biometric authentication completed. User authenticated: $_authenticated');
    if(_authenticated) {
      DiagnosticLogger.fine('Launching home screen...');
      Navigator.pushReplacement(
        context,
        NoAnimationMaterialPageRoute<HomeScreen>(
            builder: (BuildContext context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) => GradientBackground(
          begin: const Color(0xff0f3278),
          end: const Color(0xff2563b7),
          child: Stack(
            children: <Widget>[
              Positioned(
                  child: Align(
                      alignment: FractionalOffset.center,
                      child: Column(
                        mainAxisAlignment : MainAxisAlignment.center,
                        crossAxisAlignment : CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/images/fr-icon-accounts-lock.png',
                            fit: BoxFit.fitWidth,
                            width: 180.0,
                            alignment: Alignment.bottomCenter,
                          ),
                          const SizedBox(height: 8),
                          Text(
                              AppLocalizations.of(context).unLockAppTitle,
                              key: const Key('header'),
                              style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  height: 2.0)
                          ),
                        ],
                      )
                  )
              ),
              Positioned(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        _authenticate();
                      },
                      child: Text(AppLocalizations.of(context).unLockAppAuthenticateButton),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(150, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        primary: const Color(0xff0f3278),
                        onPrimary: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),//Your widget here,
                  ),
                ),
              ),
            ],
          )
      )
      ),
    );
  }

}