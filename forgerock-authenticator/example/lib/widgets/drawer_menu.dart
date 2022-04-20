/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator_example/screens/about_screen.dart';
import 'package:forgerock_authenticator_example/screens/edit_accounts/edit_accounts_screen.dart';
import 'package:forgerock_authenticator_example/screens/intro/intro_screen.dart';
import 'package:forgerock_authenticator_example/screens/notifications/notifications_screen.dart';
import 'package:forgerock_authenticator_example/screens/settings_screen.dart';
import 'package:forgerock_authenticator_example/screens/unlock/gradient_background.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';

import '../util/browser_util.dart';

class DrawerMenu extends StatelessWidget {

  const DrawerMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: GradientBackground(
        begin: const Color(0xffffffff),
        end: const Color(0xffEFF0F2),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 140.0,
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.all(30.0),
                child: Image(image: AssetImage('assets/images/fr-logo-color.png')),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              iconColor: Colors.black,
              title: TextScale(maxFactor: 1.4,
                  child: Text(AppLocalizations.of(context).actionEditAccounts,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height > 800 ? 18 : 16,
                          height: 1.3, color: Colors.black,
                          fontWeight: FontWeight.w400)
                  )
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<EditAccountsScreen>(
                      builder: (BuildContext context) => const EditAccountsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              iconColor: Colors.black,
              title: TextScale(maxFactor: 1.4,
                  child: Text(AppLocalizations.of(context).actionShowNotifications,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height > 800 ? 18 : 16,
                          height: 1.3, color: Colors.black,
                          fontWeight: FontWeight.w400)
                  )
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<NotificationScreen>(
                      builder: (BuildContext context) => const NotificationScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              iconColor: Colors.black,
              title: TextScale(maxFactor: 1.4,
                  child: Text(AppLocalizations.of(context).actionSettings,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height > 800 ? 18 : 16,
                          height: 1.3, color: Colors.black,
                          fontWeight: FontWeight.w400)
                  )
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<SettingsScreen>(
                      builder: (BuildContext context) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assistant),
              iconColor: Colors.black,
              title: TextScale(maxFactor: 1.4,
                  child: Text(AppLocalizations.of(context).actionGetStarted,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height > 800 ? 18 : 16,
                          height: 1.3, color: Colors.black,
                          fontWeight: FontWeight.w400)
                  )
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<IntroScreen>(
                      builder: (BuildContext context) => const IntroScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              iconColor: Colors.black,
              title: TextScale(maxFactor: 1.4,
                  child: Text(AppLocalizations.of(context).actionAbout,
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height > 800 ? 18 : 16,
                              height: 1.3, color: Colors.black,
                              fontWeight: FontWeight.w400)
                  )
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<AboutScreen>(
                      builder: (BuildContext context) => const AboutScreen()),
                ).then((_) => Navigator.pop(context));
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              iconColor: Colors.black,
              title: TextScale(maxFactor: 1.4,
                  child: Text(AppLocalizations.of(context).actionHelp,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height > 800 ? 18 : 16,
                          height: 1.3, color: Colors.black,
                          fontWeight: FontWeight.w400)
                  )
              ),
              onTap: () {
                launchInBrowser('https://backstage.forgerock.com/knowledge/kb/book/b15463777');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      )
    );
  }

}
