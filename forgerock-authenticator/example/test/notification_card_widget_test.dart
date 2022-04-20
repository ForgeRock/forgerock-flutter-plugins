/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:forgerock_authenticator_example/screens/notifications/notification_card.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
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

  group('Testing NotificationCard widget', () {

    testWidgets('Test 1 :: Display Approved Push Notification', (WidgetTester tester) async {
      // given
      final PushNotification pushNotification = SampleData.createRandomPushNotification();
      pushNotification.approved = true;
      pushNotification.getMechanism().issuer = 'ForgeRock';
      pushNotification.timeAdded = 1629243746838; // 2021-08-17 16:42

      await tester.pumpWidget(createWidgetForTestingWithProviders(
            child: NotificationCard(key: ValueKey<int>(pushNotification.timeAdded), notification: pushNotification),
            authenticatorProvider: authenticatorProvider,
            settingsProvider: settingsProvider
        ));
      await tester.pumpAndSettle();

      /// Make sure that all expected Notification properties are displayed in the NotificationCard...
      expect(find.text('Authentication Request for ForgeRock'), findsOneWidget); // Title

      // Status text is present and is correct...
      expect(find.text('Approved'), findsOneWidget); // Our notification is "Approved"
      expect(find.text('Expired'), findsNothing); // Should not be present
      expect(find.text('Pending'), findsNothing); // Should not be present
      expect(find.text('Denied'), findsNothing); // Should not be present

      // Status icon is present and is correct...
      expect(find.byIcon(Icons.check_circle), findsOneWidget); // Status of our notification is "Approved"
      expect(find.byIcon(Icons.error), findsNothing); // should not be present
      expect(find.byIcon(Icons.help), findsNothing); // should not be present
      expect(find.byIcon(Icons.cancel), findsNothing); // should not be present

      // Date/Time text (2021-08-17 16:42)
      expect(find.text('2021-08-17'), findsOneWidget);
      expect(find.text('16:42'), findsOneWidget);

      // Test golden
      await expectLater(find.byType(NotificationCard),
          matchesGoldenFile('goldens/notification-card-widget/test-01-approved-notification.png'));
    });

    testWidgets('Test 2 :: Display Denied Push Notification', (WidgetTester tester) async {
      // given
      final PushNotification pushNotification = SampleData.createRandomPushNotification();
      pushNotification.approved = false;  // denied notification
      pushNotification.pending = false;
      pushNotification.getMechanism().issuer = 'ForgeRock';
      pushNotification.timeAdded = 1629243746838; // 2021-08-17 16:42

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: NotificationCard(key: ValueKey<int>(pushNotification.timeAdded), notification: pushNotification),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      /// Make sure that all expected Notification properties are displayed in the NotificationCard...
      expect(find.text('Authentication Request for ForgeRock'), findsOneWidget); // Title

      // Status text is present and is correct...
      expect(find.text('Approved'), findsNothing);
      expect(find.text('Expired'), findsNothing);
      expect(find.text('Pending'), findsNothing);
      expect(find.text('Denied'), findsOneWidget);

      // Status icon is present and is correct...
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.error), findsNothing);
      expect(find.byIcon(Icons.help), findsNothing);
      expect(find.byIcon(Icons.cancel), findsOneWidget);

      // Test golden
      await expectLater(find.byType(NotificationCard),
          matchesGoldenFile('goldens/notification-card-widget/test-02-denied-notification.png'));
    });

    testWidgets('Test 3 :: Display Pending Push Notification', (WidgetTester tester) async {
      // given
      final PushNotification pushNotification = SampleData.createRandomPushNotification();
      // Pending notification is one that's not approved, is pending and timeExpired is > now
      pushNotification.approved = false;
      pushNotification.pending = true;
      pushNotification.getMechanism().issuer = 'ForgeRock';
      pushNotification.timeAdded = 1629243746838; // 2021-08-17 16:42

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: NotificationCard(key: ValueKey<int>(pushNotification.timeAdded), notification: pushNotification),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      /// Make sure that all expected Notification properties are displayed in the NotificationCard...
      expect(find.text('Authentication Request for ForgeRock'), findsOneWidget); // Title

      // Status text is present and is correct...
      expect(find.text('Approved'), findsNothing);
      expect(find.text('Expired'), findsNothing);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Denied'), findsNothing);

      // Status icon is present and is correct...
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.error), findsNothing);
      expect(find.byIcon(Icons.help), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsNothing);

      // Test golden
      await expectLater(find.byType(NotificationCard),
          matchesGoldenFile('goldens/notification-card-widget/test-03-pending-notification.png'));
    });

    testWidgets('Test 4 :: Display Expired Push Notification', (WidgetTester tester) async {
      // given
      final PushNotification pushNotification = SampleData.createRandomPushNotification();
      // Expired notification is the the one that's
      // not approved, is pending and timeExpired < now
      pushNotification.approved = false;
      pushNotification.pending = true;
      pushNotification.getMechanism().issuer = 'ForgeRock';
      pushNotification.timeAdded = 1629243746838; // 2021-08-17 16:42:26
      pushNotification.timeExpired = 1629243946838; // 2021-08-17 16:45:26

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: NotificationCard(key: ValueKey<int>(pushNotification.timeAdded), notification: pushNotification),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      /// Make sure that all expected Notification properties are displayed in the NotificationCard...
      expect(find.text('Authentication Request for ForgeRock'), findsOneWidget); // Title

      // Status text is present and is correct...
      expect(find.text('Approved'), findsNothing);
      expect(find.text('Expired'), findsOneWidget);
      expect(find.text('Pending'), findsNothing);
      expect(find.text('Denied'), findsNothing);

      // Status icon is present and is correct...
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.byIcon(Icons.help), findsNothing);
      expect(find.byIcon(Icons.cancel), findsNothing);

      // Test golden
      await expectLater(find.byType(NotificationCard),
          matchesGoldenFile('goldens/notification-card-widget/test-04-expired-notification.png'));
    });

  });
}
