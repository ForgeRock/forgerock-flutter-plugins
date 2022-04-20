/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:forgerock_authenticator_example/screens/about_screen.dart';
import 'package:forgerock_authenticator_example/screens/edit_accounts/edit_accounts_screen.dart';
import 'package:forgerock_authenticator_example/screens/notifications/notifications_screen.dart';
import 'package:forgerock_authenticator_example/screens/settings_screen.dart';
import 'package:forgerock_authenticator_example/widgets/drawer_menu.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';

import 'src/mock_authenticator_provider.dart';
import 'src/mock_settings_provider.dart';
import 'src/sample_data.dart';
import 'src/test_util.dart';

AuthenticatorProvider authenticatorProvider;
SettingsProvider settingsProvider;

void main() {
  setUp(() {
    return Future<void>(() async {
      authenticatorProvider = createMockAuthenticatorProvider();
      settingsProvider = createMockSettingsProvider();
      await loadAppFonts();
    });
  });

  group('Testing Actions Menu UI', () {

    testWidgets('Test 01 :: ActionsMenu items', (WidgetTester tester) async {

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetForTestingWithProviders(
            child: const DrawerMenu()
        ));

        const AssetImage frLogoColor = AssetImage(
            'assets/images/fr-logo-color.png'
        );
        // precache images
        final Element imageAssetFirst = find.byType(Image).evaluate().first;
        await precacheImage(frLogoColor, imageAssetFirst);
        await tester.pumpAndSettle();
      });

      // Make sure that exactly 6 menu items are present:
      expect(find.byType(Ink), findsNWidgets(6));

      // Make sure that all expected menu items are present:
      expect(find.text('Edit Accounts'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);

      expect(find.text('Show notifications'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.byIcon(Icons.assistant), findsOneWidget);

      expect(find.text('About'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);

      expect(find.text('Help'), findsOneWidget);
      expect(find.byIcon(Icons.help), findsOneWidget);

      await expectLater(find.byType(DrawerMenu),
      matchesGoldenFile('goldens/actions-menu/test-01-actions-menu-items.png'));
    });

    testWidgets('Test 02 :: Invoke "Edit Accounts"', (WidgetTester tester) async {
      final Account totpAccount = SampleData.createIndexedAccount(1);
      final List<Account> mockAccountList = <Account>[
        totpAccount
      ];
      when(authenticatorProvider.accounts).thenAnswer((_) => mockAccountList);

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const DrawerMenu(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      // Tap on 'Edit Accounts' menu item
      await tester.tap(find.text('Edit Accounts'));
      await tester.pumpAndSettle();

      // Make sure that the user has been navigated to the EditAccountsScreen
      expect(find.byType(EditAccountsScreen), findsOneWidget);
    });

    testWidgets('Test 03 :: Invoke "Show notifications"', (WidgetTester tester) async {
      // given 2 push notifications
      final PushNotification n1 = SampleData.createPushNotification('ForgeRock-approved', 1629243746838, 1629243846838, true, false);
      final PushNotification n2 = SampleData.createPushNotification('ForgeRock-pending', 1629233766838, SampleData.getTimeStampNow() + (120 * 1000), false, true);

      final List<PushNotification> testNotifications = <PushNotification>[];
      testNotifications.add(n1); // approved
      testNotifications.add(n2); // pending

      when(authenticatorProvider.notifications).thenAnswer((_) => testNotifications);

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const DrawerMenu(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      // Tap on 'Edit Accounts' menu item
      await tester.tap(find.text('Show notifications'));
      await tester.pumpAndSettle();

      // Make sure that the user has been navigated to the NotificationScreen
      expect(find.byType(NotificationScreen), findsOneWidget);
    });

    testWidgets('Test 04 :: Invoke "Settings"', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const DrawerMenu(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      // Tap on 'Edit Accounts' menu item
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Make sure that the user has been navigated to the SettingsScreen
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('Test 05 :: Invoke "About"', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetForTestingWithProviders(child: const DrawerMenu()));
      await tester.pumpAndSettle();

      // Tap on 'Edit Accounts' menu item
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      // Make sure that the user has been navigated to the AboutScreen
      expect(find.byType(AboutScreen), findsOneWidget);
    });
  });
}