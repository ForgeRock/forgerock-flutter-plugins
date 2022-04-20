/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator/models/mechanism.dart';
import 'package:forgerock_authenticator_example/helpers/biometrics_helper.dart';
import 'package:forgerock_authenticator_example/helpers/deep_link_helper.dart';
import 'package:forgerock_authenticator_example/helpers/diagnostic_logger.dart';
import 'package:forgerock_authenticator_example/helpers/push_helper.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/screens/accounts/account_add_options.dart';
import 'package:forgerock_authenticator_example/screens/unlock/unlock_app_screen.dart';
import 'package:forgerock_authenticator_example/widgets/alert.dart';
import 'package:forgerock_authenticator_example/widgets/app_bar.dart';
import 'package:forgerock_authenticator_example/widgets/drawer_menu.dart';
import 'package:forgerock_authenticator_example/widgets/no_animation_page_route.dart';
import 'package:provider/provider.dart';

import 'accounts/accounts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  static const String id = 'HomeScreen';

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();

    DiagnosticLogger.fine('Initializing HomeScreen...');

    // Check for initialLink
    DiagnosticLogger.fine('Looking for deep link on app launch');
    final String linkUri = DeepLinkHelper().initialUrl;
    if(linkUri != null) {
      DiagnosticLogger.info('App launched with DeepLink: $linkUri');
      _processDeepLink(context, linkUri);
    }

    // Check for pending Push Notifications
    _checkPendingNotifications();

    DiagnosticLogger.fine('Observing AppState in HomeScreen...');
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    DiagnosticLogger.fine('HomePage state changed: $state');
    switch (state) {
      case AppLifecycleState.resumed:
        _onResumed();
        break;
      case AppLifecycleState.paused:
        _onPaused();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _floatingButton(context),
      appBar: ForgeRockAppBar(
          title: AppLocalizations.of(context).homeScreenTitle,
      ),
      drawer: const DrawerMenu(),
      body: const AccountsScreen(),
    );
  }

  Widget _floatingButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showAddAccountOptions(context);
      },
      child: const Icon(
        Icons.add,
        key: Key('qr-code-scanner'),
        size: 30,
        color: Colors.white,
      ),
      backgroundColor: const Color(0xFF006AC8),
    );
  }

  void _showAddAccountOptions(BuildContext context) {
    showModalBottomSheet<AddAccountOptions>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return const AddAccountOptions();
        });
  }

  void _processDeepLink(BuildContext context, String linkUri) {
    final BuildContext rootContext = context.findRootAncestorStateOfType<NavigatorState>().context;
    Provider
        .of<AuthenticatorProvider>(context, listen: false)
        .addAccount(linkUri)
        .then((Mechanism value) {
          DeepLinkHelper().clearLatestUri();
          if(value != null) {
            showAddAccountResult(rootContext, true);
          }
        })
        .catchError((Object error) {
          DiagnosticLogger.severe('Error creating account via deeplink', error);
          alert(rootContext, AppLocalizations
              .of(rootContext)
              .errorTitle, error.toString());
        });
  }

  Future<void> _checkPendingNotifications() async {
    DiagnosticLogger.fine('Pending notifications check');
    PushHelper().processPendingNotification(context: context);
  }

  Future<void> _onResumed() async {
    // Check App lock
    final bool shouldShowUnlockScreen = await BiometricsHelper.isAuthenticationRequired();
    if(shouldShowUnlockScreen) {
      DiagnosticLogger.fine('App in background for more than ${BiometricsHelper.pinLockMillis/1000}s, requesting Local Authentication.');
      Navigator.pushReplacement(
        context,
        NoAnimationMaterialPageRoute<UnlockApp>(
            builder: (BuildContext context) => const UnlockApp()),
      );
    } else {
      DiagnosticLogger.fine('App resumed, but no Authentication required.');

      // Check Deep Link
      DiagnosticLogger.fine('Looking for deep link on app resume');
      final String linkUri = DeepLinkHelper().latestUrl;
      if(linkUri != null) {
        DiagnosticLogger.info('App resumed with DeepLink: $linkUri');
        _processDeepLink(context, linkUri);
      }

      // Check pending notifications
      Future<void>.delayed(const Duration(milliseconds: 400), _checkPendingNotifications);
    }
  }

  Future<void> _onPaused() async {
    // Check App lock
    BiometricsHelper.onAppInactive();
  }

}






