/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator/models/push_notification.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:forgerock_authenticator_example/screens/notifications/notification_card.dart';
import 'package:forgerock_authenticator_example/screens/notifications/notification_dialog.dart';
import 'package:forgerock_authenticator_example/screens/notifications/notification_list.dart';
import 'package:forgerock_authenticator_example/widgets/account_logo.dart';
import 'package:forgerock_authenticator_example/widgets/empty_list.dart';
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

  group('Testing NotificationList widget', () {

    testWidgets('Test 1 :: NotificationList with no notifications', (WidgetTester tester) async {
      when(authenticatorProvider.notifications).thenAnswer((_) => <PushNotification>[]);

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetForTestingWithProviders(
            child: const NotificationList(),
            authenticatorProvider: authenticatorProvider,
            settingsProvider: settingsProvider
        ));

        // precache image-empty image
        final Element emptyListImageWrapper = find.byKey(const Key('image-empty')).evaluate().first;
        final Image emptyListImage = emptyListImageWrapper.widget as Image;
        await precacheImage(emptyListImage.image, emptyListImageWrapper);
        await tester.pumpAndSettle();
      });

      expect(find.byType(EmptyList), findsOneWidget);  // EmptyList widget is present

      expect(find.descendant
        (of: find.byType(EmptyList),
          matching: find.byKey(const Key('image-empty'))),
          findsOneWidget); // Image is present

      expect(find.descendant
        (of: find.byType(EmptyList),
          matching: find.text('No notifications')),
          findsOneWidget); // Header text is present

      expect(find.descendant
        (of: find.byType(EmptyList),
          matching: find.text('To see a notification list, register a Push account')),
          findsOneWidget); // Description text is present

      // Test golden
      await expectLater(find.byType(NotificationList),
          matchesGoldenFile('goldens/notification-list-widget/test-01-empty-notification-list.png'));
    });

    testWidgets('Test 2 :: NotificationList with ONE Notification', (WidgetTester tester) async {
      // given
      final PushNotification n1 = SampleData.createPushNotification('ForgeRock', 1629243746838, 1629243846838, true, false);

      final List<PushNotification> testNotifications = <PushNotification>[];
      testNotifications.add(n1);

      when(authenticatorProvider.notifications).thenAnswer((_) => testNotifications);
      await tester.pumpWidget(createWidgetForTestingWithProviders(
            child: const NotificationList(),
            authenticatorProvider: authenticatorProvider,
            settingsProvider: settingsProvider
        ));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationList), findsOneWidget);  // NotificationList widget is present

      expect(find.descendant
        (of: find.byType(NotificationList),
          matching: find.byType(NotificationCard)),
          findsOneWidget); // Exactly one NotificationCard is present

      // Test golden
      await expectLater(find.byType(NotificationList),
          matchesGoldenFile('goldens/notification-list-widget/test-02-one-notification-present.png'));
    });

    testWidgets('Test 3 :: NotificationList with a couple of notification', (WidgetTester tester) async {
      // given
      final PushNotification n1 = SampleData.createPushNotification('ForgeRock-approved', 1629243746838, 1629243846838, true, false);
      final PushNotification n2 = SampleData.createPushNotification('ForgeRock-expired', 1629233766838, 1629243846838, false, true);
      final PushNotification n3 = SampleData.createPushNotification('ForgeRock-denied', 1629233766838, SampleData.getTimeStampNow() + (120 * 1000), false, false);
      final PushNotification n4 = SampleData.createPushNotification('ForgeRock-pending', 1629233766838, SampleData.getTimeStampNow() + (120 * 1000), false, true);

      final List<PushNotification> testNotifications = <PushNotification>[];
      testNotifications.add(n1); // approved
      testNotifications.add(n2); // expired
      testNotifications.add(n3); // denied
      testNotifications.add(n4); // pending

      when(authenticatorProvider.notifications).thenAnswer((_) => testNotifications);
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const NotificationList(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationList), findsOneWidget);

      expect(find.descendant
        (of: find.byType(NotificationList),
          matching: find.byType(NotificationCard)),
          findsNWidgets(4)); // Exactly 4 NotificationCard are present

      // Test golden
      await expectLater(find.byType(NotificationList),
          matchesGoldenFile('goldens/notification-list-widget/test-03-couple-notification-present.png'));
    });

    testWidgets('Test 4 :: Test NotificationDialog details', (WidgetTester tester) async {
      // given
      final PushNotification n1 = SampleData.createPushNotification('Microsoft-approved', 1629243746838, 1629243846838, true, false);
      final PushNotification n2 = SampleData.createPushNotification('Microsoft-expired', 1629233766838, 1629243846838, false, true);
      final PushNotification n3 = SampleData.createPushNotification('Microsoft-denied', 1629233766838, SampleData.getTimeStampNow() + (120 * 1000), false, false);
      final PushNotification n4 = SampleData.createPushNotification('Microsoft-pending', 1629233766838, SampleData.getTimeStampNow() + (120 * 1000), false, true);

      final List<PushNotification> testNotifications = <PushNotification>[];
      testNotifications.add(n1); // approved
      testNotifications.add(n2); // expired
      testNotifications.add(n3); // denied
      testNotifications.add(n4); // pending

      final Account randomAccount = SampleData.createRandomAccount();
      randomAccount.issuer = 'Microsoft';
      randomAccount.accountName = 'Random';
      when(authenticatorProvider.getAccountByMechanismUID(n3.mechanismUID)).thenAnswer((_) => randomAccount);

      when(authenticatorProvider.notifications).thenAnswer((_) => testNotifications);

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const NotificationList(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Approved'));
      await eventFiring(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(NotificationDialog), findsNothing);

      await tester.tap(find.text('Expired'));
      await eventFiring(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(NotificationDialog), findsNothing);

      await tester.tap(find.text('Denied'));
      await eventFiring(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(NotificationDialog), findsOneWidget);

      // Account logo is present only when the account can be located...
      expect(find.descendant(of: find.byType(NotificationDialog),
          matching: find.byType(AccountLogo)),
          findsOneWidget);

      // Test description text
      expect(find.descendant(of: find.byType(NotificationDialog),
          matching: find.text('Authentication request for Microsoft')),
          findsOneWidget);

      // Another description...
      expect(find.descendant(of: find.byType(NotificationDialog),
          matching: find.text('Use the buttons to Accept or Reject the request.')),
          findsOneWidget);

      // Make sure that exactly 2 buttons are present
      expect(find.descendant(of: find.byType(NotificationDialog),
          matching: find.byType(ElevatedButton)),
          findsNWidgets(2));

      expect(find.descendant(of: find.byType(ElevatedButton),
          matching: find.text('Accept')),
          findsOneWidget);

      expect(find.descendant(of: find.byType(ElevatedButton),
          matching: find.text('Reject')),
          findsOneWidget);

      // Test golden will fail due to random color generation for the account avatar
      await expectLater(find.byType(NotificationDialog),
          matchesGoldenFile('goldens/notification-list-widget/test-04-tap-on-denied-notification.png'));

      // Dismiss the NotificationDialog by tapping outside it...
      await tester.tapAt(const Offset(10.0, 10.0));
      await eventFiring(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(NotificationDialog), findsNothing);

      await tester.tap(find.text('Pending'));
      await eventFiring(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(NotificationDialog), findsOneWidget);

      // Account logo is present only when the account can be located...
      expect(find.descendant(of: find.byType(NotificationDialog),
          matching: find.byType(AccountLogo)),
          findsNothing);

      // Test description text
      expect(find.descendant(of: find.byType(NotificationDialog),
          matching: find.text('Authentication request')),
          findsOneWidget);

      // Test golden
      await expectLater(find.byType(NotificationDialog),
          matchesGoldenFile('goldens/notification-list-widget/test-04-tap-on-pending-notification.png'));
    });

    testWidgets('Test 5 :: NotificationList with a big number of notification', (WidgetTester tester) async {
      // given
      final PushNotification n1 = SampleData.createPushNotification('ForgeRock', 1629243746838, 1629243846838, true, false);
      final PushNotification n2 = SampleData.createPushNotification('Simens', 1629233766838, 1629243846838, false, true);
      final PushNotification n3 = SampleData.createPushNotification('Microsoft', 1629233766838, SampleData.getTimeStampNow() + (120 * 1000), false, false);
      final PushNotification n4 = SampleData.createPushNotification('Facebook', 1629233766838, SampleData.getTimeStampNow() + (120 * 1000), false, true);
      final PushNotification n5 = SampleData.createPushNotification('Google', 1629243746838, 1629243846838, true, false);
      final PushNotification n6 = SampleData.createPushNotification('Git', 1629233766838, 1629243846838, false, true);
      final PushNotification n7 = SampleData.createPushNotification('RBC', 1629233766838, SampleData.getTimeStampNow() + (120 * 1000), false, false);
      final PushNotification n8 = SampleData.createPushNotification('TD', 1629233766838, SampleData.getTimeStampNow() + (120 * 1000), false, true);
      final PushNotification n9 = SampleData.createPushNotification('BBB', 1629243746838, 1629243846838, true, false);
      final PushNotification n10 = SampleData.createPushNotification('Coleman', 1629233766838, 1629243846838, false, true);
      final PushNotification n11 = SampleData.createPushNotification('Comox Valley Mushrooms', 1629233766838, SampleData.getTimeStampNow() + (120 * 1000), false, false);
      final PushNotification n12 = SampleData.createPushNotification('Netflix', 1629233766838, SampleData.getTimeStampNow() + (120 * 1000), false, true);
      final PushNotification n13 = SampleData.createPushNotification('McKesson', 1629243746838, 1629243846838, true, false);
      final PushNotification n14 = SampleData.createPushNotification('CA', 1629233766838, 1629243846838, false, true);
      final PushNotification n15 = SampleData.createPushNotification('Layer7 Tech', 1629233766838, SampleData.getTimeStampNow() + (120 * 1000), false, false);
      final PushNotification n16 = SampleData.createPushNotification('Musala', 1629233766838, SampleData.getTimeStampNow() + (120 * 1000), false, true);

      final List<PushNotification> testNotifications = <PushNotification>[];
      testNotifications.add(n1);
      testNotifications.add(n2);
      testNotifications.add(n3);
      testNotifications.add(n4);
      testNotifications.add(n5);
      testNotifications.add(n6);
      testNotifications.add(n7);
      testNotifications.add(n8);
      testNotifications.add(n9);
      testNotifications.add(n10);
      testNotifications.add(n11);
      testNotifications.add(n12);
      testNotifications.add(n13);
      testNotifications.add(n14);
      testNotifications.add(n15);
      testNotifications.add(n16);

      when(authenticatorProvider.notifications).thenAnswer((_) => testNotifications);
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const NotificationList(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationList), findsOneWidget);

      // Test golden
      await expectLater(find.byType(NotificationList),
          matchesGoldenFile('goldens/notification-list-widget/test-05-lots-of-notifications-initial.png'));

      expect(find.descendant
        (of: find.byType(NotificationList),
          matching: find.byType(NotificationCard)),
          findsNWidgets(10)); // Exactly 4 NotificationCard are present

      // Check waht's visible and what not...
      expect(find.text('Authentication Request for ForgeRock'), findsOneWidget);
      expect(find.text('Authentication Request for Coleman'), findsOneWidget);
      expect(find.text('Authentication Request for Comox Valley Mushrooms'), findsNothing);

      // Scroll to the bottom and ensure that we can see the last notification...
      await tester.drag(find.byType(NotificationList), const Offset(0, -1200));
      await tester.pumpAndSettle();

      // Test golden
      await expectLater(find.byType(NotificationList),
          matchesGoldenFile('goldens/notification-list-widget/test-05-lots-of-notifications-after.png'));

      // Check waht's visible and what not...
      expect(find.text('Authentication Request for ForgeRock'), findsNothing);
      expect(find.text('Authentication Request for Comox Valley Mushrooms'), findsOneWidget);
      expect(find.text('Authentication Request for Musala'), findsOneWidget);
    });

  });
}
