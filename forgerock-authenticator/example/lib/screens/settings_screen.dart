/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator_example/helpers/diagnostic_logger.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:forgerock_authenticator_example/widgets/alert.dart';
import 'package:forgerock_authenticator_example/widgets/app_bar.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {

  const SettingsScreen({Key key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _toggleAppLock = false;
  bool _toggleCloudBackup = false;
  bool _toggleCopyCode = false;
  bool _toggleTapToReveal = false;
  bool _toggleDisableScreenshot = false;

  @override
  void initState() {
    super.initState();
    _toggleAppLock = Provider.of<SettingsProvider>(context, listen: false).lock;
    _toggleCloudBackup = Provider.of<SettingsProvider>(context, listen: false).synchronization;
    _toggleTapToReveal = !Provider.of<SettingsProvider>(context, listen: false).visibility;
    _toggleCopyCode = Provider.of<SettingsProvider>(context, listen: false).copyCode;
    _toggleDisableScreenshot = Provider.of<SettingsProvider>(context, listen: false).disableScreenshot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: ForgeRockAppBar(
          actions: const <Widget>[],
          title: AppLocalizations.of(context).settingsScreenTitle,
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 4),
                    enableAppLockItem(context),
                    tapToCopyCodeItem(context),
                    tapToRevealItem(context),
                    if(Platform.isAndroid) disableScreenshotItem(context),
                  ],
                )
            )
        )
    );
  }

  Widget enableAppLockItem(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SwitchListTile(
            title: TextScale(child: Text(AppLocalizations.of(context).settingsScreenAppLockTitle)),
            secondary: const Icon(Icons.lock),
            onChanged: (bool value) async {
              final bool success = await setLock(context);
              setState(() {
                _toggleAppLock = success ? value : !value;
              });
            },
            value: _toggleAppLock,
          ),
          TextScale(child: Text(AppLocalizations.of(context).settingsScreenAppLockDescription)),
          const SizedBox(height: 4),
          const Divider(thickness: 1.2),
        ]
    );
  }

  Widget enableCloudBackupItem(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SwitchListTile(
            title: TextScale(child: Text(AppLocalizations.of(context).settingsScreenCloudSynchronizationTitle)),
            secondary: const Icon(Icons.cloud),
            onChanged: (bool value) {
              setState(() {
                Provider.of<SettingsProvider>(context, listen: false).toggleSynchronization();
                _toggleCloudBackup = value;
              });
            },
            value: _toggleCloudBackup,
          ),
          TextScale(child: Text(AppLocalizations.of(context).settingsScreenCloudSynchronizationDescription)),
          const SizedBox(height: 4),
          const Divider(thickness: 1.2),
        ]
    );
  }

  Widget tapToCopyCodeItem(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SwitchListTile(
            title: TextScale(child: Text(AppLocalizations.of(context).settingsScreenCopyCodeTitle)),
            secondary: const Icon(Icons.copy),
            onChanged: (bool value) {
              setState(() {
                Provider.of<SettingsProvider>(context, listen: false).toggleCopyCode();
                _toggleCopyCode = value;
              });
            },
            value: _toggleCopyCode,
          ),
          TextScale(child: Text(AppLocalizations.of(context).settingsScreenCopyCodeDescription)),
          const SizedBox(height: 4),
          const Divider(thickness: 1.2),
        ]
    );
  }

  Widget tapToRevealItem(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SwitchListTile(
            title: TextScale(child: Text(AppLocalizations.of(context).settingsScreenTapToRevealTitle)),
            secondary: const Icon(Icons.visibility),
            onChanged: (bool value) async {
              setState(() {
                _toggleTapToReveal = value;
              });
              await Provider.of<SettingsProvider>(context, listen: false).toggleVisibility();
            },
            value: _toggleTapToReveal,
          ),
          TextScale(child: Text(AppLocalizations.of(context).settingsScreenTapToRevealDescription)),
          const SizedBox(height: 4),
          const Divider(thickness: 1.2),
        ]
    );
  }

  Widget disableScreenshotItem(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SwitchListTile(
            title: TextScale(child: Text(AppLocalizations.of(context).settingsScreenDisableScreenshotCaptureTitle)),
            secondary: const Icon(Icons.screenshot),
            onChanged: (bool value) async {
              final bool success = await setDisableScreenshot(context, value);
              setState(() {
                _toggleDisableScreenshot = success ? value : !value;
              });
            },
            value: _toggleDisableScreenshot,
          ),
          TextScale(child: Text(AppLocalizations.of(context).settingsScreenDisableScreenshotCaptureDescription)),
          const SizedBox(height: 4),
          const Divider(thickness: 1.2)
        ]
    );
  }

}

Future<bool> setDisableScreenshot(BuildContext context, bool disableScreenshot) async {
  bool success;
  if (disableScreenshot) {
    success = await AuthenticatorProvider.disableScreenshot();
  } else {
    success = await AuthenticatorProvider.enableScreenshot();
  }
  if(success) {
    Provider.of<SettingsProvider>(context, listen: false).toggleDisableScreenshot();
  }
  return success;
}

Future<bool> setLock(BuildContext context) async {
  final LocalAuthentication _auth = LocalAuthentication();

  final bool isAvailable = await _auth.canCheckBiometrics;
  if (isAvailable) {
    final List<BiometricType> list = await _auth.getAvailableBiometrics();
    DiagnosticLogger.fine('Biometric available: $list');
    return _authenticate(context, _auth, true);
  } else {
    DiagnosticLogger.fine('Biometric NOT available! Trying PIN/pattern...');
    return _authenticate(context, _auth, false);
  }
}

Future<bool> _authenticate(BuildContext context, LocalAuthentication _auth, bool biometricOnly) async {
  try {
    final bool didAuthenticate = await _auth.authenticate(
      useErrorDialogs: true,
      stickyAuth: true,
      biometricOnly: biometricOnly,
      localizedReason: AppLocalizations.of(context).unLockAppLocalizedReason,
    );

    if(didAuthenticate) {
      Provider.of<SettingsProvider>(context, listen: false).toggleLock();
      return true;
    } else {
      return false;
    }
  } on PlatformException catch (e) {
    DiagnosticLogger.severe('Error authenticating using biometrics', e);
    final bool lockEnabled = Provider.of<SettingsProvider>(context, listen: false).lock;
    if (e.code == auth_error.notEnrolled && !lockEnabled) {
      alert(context, AppLocalizations.of(context).errorTitle, AppLocalizations.of(context).unLockAppErrorBiometricNotEnrolled);
    } else if (e.code == auth_error.notEnrolled && lockEnabled) {
      alert(context, AppLocalizations.of(context).errorTitle, AppLocalizations.of(context).unLockAppErrorRemovedLock);
    } else if (e.code == auth_error.notAvailable) {
      alert(context, AppLocalizations.of(context).errorTitle, AppLocalizations.of(context).unLockAppErrorNoSecurity);
    } else {
      alert(context, AppLocalizations.of(context).errorTitle, e.message);
    }
    return false;
  }
}
