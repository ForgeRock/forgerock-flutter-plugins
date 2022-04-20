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
import 'package:forgerock_authenticator/models/mechanism.dart';
import 'package:forgerock_authenticator/models/oath_mechanism.dart';
import 'package:forgerock_authenticator/models/oath_token_code.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:forgerock_authenticator_example/screens/accounts/account_card.dart';
import 'package:forgerock_authenticator_example/screens/accounts/account_detail.dart';
import 'package:forgerock_authenticator_example/widgets/account_logo.dart';
import 'package:forgerock_authenticator_example/widgets/account_square_avatar.dart';
import 'package:forgerock_authenticator_example/widgets/count_down_timer.dart';
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

  /*
   * AccountCard widget contains of 2 rows:
   *  First row contains:
   *  - Account icon
   *  - Account issuer
   *  - Account name
   *
   *  Second row contains AccountDetails - (tested separately):
   *  - Code (TOTP or HOTP)
   *  - CountDown controller
   *  - TokenType (TOTP/HOTP)
   *  - Duration
   *
   */

  group('Testing AccountCard widget', () {

    testWidgets('Test 1 :: Display TOTP account with 6 digits code', (WidgetTester tester) async {
      // given
      final Account totpAccount = SampleData.createIndexedAccount(1);
      when(authenticatorProvider.getOathTokenCode(any)).thenAnswer((_) async => OathTokenCode('123456', 30000, 0, TokenType.TOTP));

      // Prepare and pump a test AccountCard widget
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: AccountCard(key: ValueKey<String>(totpAccount.id), account: totpAccount, expanded: true),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await eventFiring(tester);

      expect(find.byType(AccountLogo), findsOneWidget);  // AccountLogo is present
      expect(find.byType(AccountSquareAvatar), findsOneWidget);  // AccountSquareAvatar is present
      expect(find.descendant(of: find.byType(AccountSquareAvatar), matching: find.text('A')), findsOneWidget); // AccountSquareAvatar contains the inital letter of the issuer
      expect(find.text(totpAccount.issuer), findsOneWidget);
      expect(find.text(totpAccount.accountName), findsOneWidget);

      // Test the account card icons...
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.change_circle_outlined)), findsNothing);
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.circle_notifications_outlined)), findsNothing);
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.copy)), findsOneWidget);

      // AccountCard contains AccountDetails...
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byType(AccountDetail)), findsOneWidget);

      // AccountDetails widget contains the following:
      expect(find.descendant(of: find.byType(AccountDetail), matching: find.byKey(const Key('copyAction'))), findsOneWidget); // copyAction button is present for TOTP accounts
      expect(find.descendant(of: find.byType(AccountDetail), matching: find.text('123 456')), findsOneWidget); // The OTP code is displayed properly
      expect(find.descendant(of: find.byType(AccountDetail), matching: find.byType(AnimatedCountDownTimer)), findsOneWidget); // AnimatedCountDownTimer widget is present
      expect(find.descendant(of: find.byType(AccountDetail), matching: find.byKey(const Key('refreshAction'))), findsNothing); // refreshAction widget is NOT present for TOTP accounts

      // By default the AccountDetails are visible
      expect(find.byKey(const Key('accountDetailHidden')), findsNothing);
      expect(find.byKey(const Key('accountDetailVisible')), findsOneWidget);

      // Test golden
      await expectLater(find.byType(AccountCard),
          matchesGoldenFile('goldens/account-card-widget/test-01-totp-6-digits.png'));
    });

    testWidgets('Test 2 :: Display HOTP account with 8 digits code', (WidgetTester tester) async {
      // given
      final Account hotpAccount = SampleData.createIndexedAccount(1, Mechanism.OATH, TokenType.HOTP);
      when(authenticatorProvider.getOathTokenCode(any)).thenAnswer((_) async => OathTokenCode('12345678', 30000, 0, TokenType.HOTP));

      // Prepare and pump a test AccountCard widget
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: AccountCard(key: ValueKey<String>(hotpAccount.id), account: hotpAccount, expanded: true),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await eventFiring(tester);

      expect(find.byType(AccountLogo), findsOneWidget);  // AccountLogo is present
      expect(find.byType(AccountSquareAvatar), findsOneWidget);  // AccountSquareAvatar is present
      expect(find.descendant(of: find.byType(AccountSquareAvatar), matching: find.text('A')), findsOneWidget); // AccountSquareAvatar contains the inital letter of the issuer
      expect(find.text(hotpAccount.issuer), findsOneWidget);
      expect(find.text(hotpAccount.accountName), findsOneWidget);

      // Test the account card icons...
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.change_circle_outlined)), findsOneWidget);
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.circle_notifications_outlined)), findsNothing);
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.delete)), findsNothing);
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.copy)), findsOneWidget);

      // AccountCard contains AccountDetails...
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byType(AccountDetail)), findsOneWidget);

      // AccountDetails widget contains the following:
      expect(find.descendant(of: find.byType(AccountDetail), matching: find.text('1234 5678')), findsOneWidget); // The OTP code is displayed properly
      expect(find.descendant(of: find.byType(AccountDetail), matching: find.byType(AnimatedCountDownTimer)), findsNothing); // AnimatedCountDownTimer widget is NOT present for HOTP accounts.
      expect(find.descendant(of: find.byType(AccountDetail), matching: find.byKey(const Key('refreshAction'))), findsOneWidget); // refreshAction widget is present for HOTP accounts

      // By default the AccountDetails are visible
      expect(find.byKey(const Key('accountDetailHidden')), findsNothing);
      expect(find.byKey(const Key('accountDetailVisible')), findsOneWidget);

      // Test golden
      await expectLater(find.byType(AccountCard),
          matchesGoldenFile('goldens/account-card-widget/test-02-hotp-8-digits.png'));
    });

    testWidgets('Test 3 :: Display PUSH account', (WidgetTester tester) async {
      // given
      final Account pushAccount = SampleData.createIndexedAccount(1, Mechanism.PUSH);
      when(authenticatorProvider.getOathTokenCode(any)).thenAnswer((_) async => null);

      // Prepare and pump a test AccountCard widget
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: AccountCard(key: ValueKey<String>(pushAccount.id), account: pushAccount, expanded: true),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await eventFiring(tester);

      expect(find.byType(AccountLogo), findsOneWidget);  // AccountLogo is present
      expect(find.byType(AccountSquareAvatar), findsOneWidget);  // AccountSquareAvatar is present
      expect(find.descendant(of: find.byType(AccountSquareAvatar), matching: find.text('A')), findsOneWidget); // AccountSquareAvatar contains the inital letter of the issuer

      expect(find.text(pushAccount.issuer), findsOneWidget);
      expect(find.text(pushAccount.accountName), findsOneWidget);

      // Test the account card icons...
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.change_circle_outlined)), findsNothing);
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.circle_notifications_outlined)), findsOneWidget);
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.copy)), findsNothing);

      // AccountCard contains AccountDetails...
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byType(AccountDetail)), findsOneWidget);

      // AccountDetails is visible for PUSH accounts
      expect(find.byKey(const Key('accountDetailHidden')), findsNothing);
      expect(find.byKey(const Key('accountDetailVisible')), findsOneWidget);

      // Test golden
      await expectLater(find.byType(AccountCard),
          matchesGoldenFile('goldens/account-card-widget/test-03-push-account.png'));
    });

    testWidgets('Test 4 :: Display OATH account with hidden code', (WidgetTester tester) async {
      // given
      final Account totpAccount = SampleData.createIndexedAccount(1);
      when(authenticatorProvider.getOathTokenCode(any)).thenAnswer((_) async => OathTokenCode('12345678', 30000, 0, TokenType.HOTP));

      // Prepare and pump a test AccountCard widget
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: AccountCard(key: ValueKey<String>(totpAccount.id), account: totpAccount, expanded: false),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await eventFiring(tester);

      expect(find.text('A'), findsOneWidget);
      expect(find.text(totpAccount.issuer), findsOneWidget);
      expect(find.text(totpAccount.accountName), findsOneWidget);
      expect(find.byType(AccountDetail), findsOneWidget);

      // Test golden
      await expectLater(find.byType(AccountCard),
          matchesGoldenFile('goldens/account-card-widget/test-04-account-card-hidden-code.png'));
    });


   testWidgets('Test 5 :: Display account with TOTP and PUSH mechanisms', (WidgetTester tester) async {
      // given
      final Account account = SampleData.createIndexedAccount(1);
      when(authenticatorProvider.getOathTokenCode(any)).thenAnswer((_) async => OathTokenCode('123456', 30000, 0, TokenType.TOTP));

      // Add a PUSH mechanism to the account
      account.mechanismList.add(SampleData.createRandomMechanism(account.issuer, account.accountName, Mechanism.PUSH));

      // Prepare and pump a test AccountCard widget
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: AccountCard(key: ValueKey<String>(account.id), account: account, expanded: true),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await eventFiring(tester);

      expect(find.byType(AccountLogo), findsOneWidget);  // AccountLogo is present
      expect(find.byType(AccountSquareAvatar), findsOneWidget);  // AccountSquareAvatar is present
      expect(find.descendant(of: find.byType(AccountSquareAvatar), matching: find.text('A')), findsOneWidget); // AccountSquareAvatar contains the inital letter of the issuer

      expect(find.text(account.issuer), findsOneWidget);
      expect(find.text(account.accountName), findsOneWidget);

      // Test the account card icons...should show both TOTP and PUSH icons (and nothing else...)
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.change_circle_outlined)), findsNothing);
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.circle_notifications_outlined)), findsNothing);
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.copy)), findsOneWidget);

      // AccountCard contains AccountDetails...
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byType(AccountDetail)), findsOneWidget);

      // AccountDetails widget contains the following:
      expect(find.descendant(of: find.byType(AccountDetail), matching: find.text('123 456')), findsOneWidget); // The OTP code is displayed properly
      expect(find.descendant(of: find.byType(AccountDetail), matching: find.byType(AnimatedCountDownTimer)), findsOneWidget); // AnimatedCountDownTimer widget is present
      expect(find.descendant(of: find.byType(AccountDetail), matching: find.byKey(const Key('refreshAction'))), findsNothing); // refreshAction widget is NOT present for TOTP accounts

      // By default the AccountDetails are visible
      expect(find.byKey(const Key('accountDetailHidden')), findsNothing);
      expect(find.byKey(const Key('accountDetailVisible')), findsOneWidget);

      // Test golden
      await expectLater(find.byType(AccountCard),
          matchesGoldenFile('goldens/account-card-widget/test-05-account-with-totp-and-push-01.png'));

      await tester.drag(find.byType(AccountDetail), const Offset(-600.0, 0.0), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Test golden
      await expectLater(find.byType(AccountCard),
          matchesGoldenFile('goldens/account-card-widget/test-05-account-with-totp-and-push-02.png'));

      // We should now see the PUSH account:
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.circle_notifications_outlined)), findsOneWidget);
      expect(find.descendant(of: find.byType(AccountDetail), matching: find.text('Last login attempt:')), findsOneWidget);

      // The OTP account details should not be visible:
      expect(find.descendant(of: find.byType(AccountDetail), matching: find.text('123 456')), findsNothing);
      expect(find.descendant(of: find.byType(AccountCard), matching: find.byIcon(Icons.copy)), findsNothing);
      expect(find.descendant(of: find.byType(AccountDetail), matching: find.byType(AnimatedCountDownTimer)), findsNothing);
    });
  });
}
