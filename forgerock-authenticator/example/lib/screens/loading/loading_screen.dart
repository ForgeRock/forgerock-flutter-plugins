/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:forgerock_authenticator_example/screens/intro/intro_screen.dart';
import 'package:forgerock_authenticator_example/screens/loading/restore_previous_data.dart';
import 'package:forgerock_authenticator_example/screens/unlock/unlock_app_screen.dart';
import 'package:provider/provider.dart';

import '../home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key key}) : super(key: key);

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {

  @override
  void initState() {
    super.initState();
    _loadWidget();
  }

  Future<void> _loadWidget() async {
    return Timer(Duration.zero, _preLoadCheck);
  }

  Future<void> _preLoadCheck() async {
    if(Platform.isIOS) {
      final bool hasAlreadyLaunched = await AuthenticatorProvider.hasAlreadyLaunched();
      final int numberOfAccounts = Provider.of<AuthenticatorProvider>(context, listen: false).accounts.length;
      final bool isNewAccountIndex = Provider.of<AuthenticatorProvider>(context, listen: false).isNewAccountIndex();
      if(!hasAlreadyLaunched && numberOfAccounts > 0 && isNewAccountIndex) {
        showDialog<Widget>(context: context, builder: (BuildContext context) {
          return const RestorePreviousData();
        }).then((Widget value) {
          _checkFirstSeen();
        });
      } else {
        _checkFirstSeen();
      }
    } else {
      _checkFirstSeen();
    }
  }

  Future<void> _checkFirstSeen() async {
    final bool _seen = await SettingsProvider.isIntroDone();
    if (_seen) {
      final bool isAppLockEnabled = await SettingsProvider.isLockEnabled();
      if (isAppLockEnabled) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<HomeScreen>(builder: (BuildContext context) => const UnlockApp()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<HomeScreen>(builder: (BuildContext context) => const HomeScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<IntroScreen>(builder: (BuildContext context) => const IntroScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(),
    );
  }

}
