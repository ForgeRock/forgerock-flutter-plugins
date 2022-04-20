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
import 'package:forgerock_authenticator/models/oath_mechanism.dart';
import 'package:forgerock_authenticator/models/oath_token_code.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:forgerock_authenticator_example/screens/accounts/account_detail.dart';
import 'package:forgerock_authenticator_example/util/token_util.dart';
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

  group('Testing AccountDetail widget', () {

    testWidgets('Test 1 :: HOTP Account Details', (WidgetTester tester) async {
      // given
      final Account hotpAccount = SampleData.createIndexedAccount(1);
      final Completer<OathTokenCode> completer = Completer<OathTokenCode>();
      final OathTokenCode oathTokenCode = OathTokenCode('111111', 1000, 11000, TokenType.HOTP);

      // when
      when(authenticatorProvider.getOathTokenCode(hotpAccount.getOathMechanism().id)).thenAnswer((_) => completer.future);
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: AccountDetail(key: ValueKey<String>(hotpAccount.id), account: hotpAccount, isOTP: true),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));

      // then
      completer.complete(oathTokenCode);
      await eventFiring(tester);

      expect(find.text(formatCode(oathTokenCode)), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
      expect(find.byIcon(Icons.change_circle_outlined), findsOneWidget);
      expect(find.byType(AnimatedCountDownTimer), findsNothing);

      // Test golden
      await expectLater(find.byType(AccountDetail),
          matchesGoldenFile('goldens/account-detail-widget/test-01-hotp-account-details-defaults.png'));
    });

    testWidgets('Test 2 :: Tap on the refresh icon', (WidgetTester tester) async {
      // given
      final Account hotpAccount = SampleData.createIndexedAccount(1);
      final Completer<OathTokenCode> completer = Completer<OathTokenCode>();
      final OathTokenCode oathTokenCode = OathTokenCode('111111', 1000, 11000, TokenType.HOTP);

      // when
      when(authenticatorProvider.getOathTokenCode(hotpAccount.getOathMechanism().id)).thenAnswer((_) => completer.future);
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: AccountDetail(key: ValueKey<String>(hotpAccount.id), account: hotpAccount, isOTP: true),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));

      completer.complete(oathTokenCode);
      await eventFiring(tester);

      expect(find.text(formatCode(oathTokenCode)), findsOneWidget);
      expect(find.byIcon(Icons.change_circle_outlined), findsOneWidget);

      // Test golden
      await expectLater(find.byType(AccountDetail),
          matchesGoldenFile('goldens/account-detail-widget/test-02a-hotp-account-before-refresh.png'));

      // -------------------
      final Completer<OathTokenCode> nextCompleter = Completer<OathTokenCode>();
      final OathTokenCode nextOathTokenCode = OathTokenCode('222222', 1000, 11000, TokenType.HOTP);
      when(authenticatorProvider.getOathTokenCode(hotpAccount.getOathMechanism().id)).thenAnswer((_) => nextCompleter.future);
      nextCompleter.complete(nextOathTokenCode);

      // tap on the refresh icon
      await tester.tap(find.byIcon(Icons.change_circle_outlined));
      await tester.pumpAndSettle();

      expect(find.text(formatCode(nextOathTokenCode)), findsOneWidget);
      expect(find.byIcon(Icons.change_circle_outlined), findsOneWidget);

      // Test golden
      await expectLater(find.byType(AccountDetail),
          matchesGoldenFile('goldens/account-detail-widget/test-02b-hotp-account-after-refresh.png'));
    });

    testWidgets('Test 3 :: HOTP with 8 digits details correctly', (WidgetTester tester) async {
      // given
      final Account hotpAccount = SampleData.createIndexedAccount(1);
      final Completer<OathTokenCode> completer = Completer<OathTokenCode>();
      final OathTokenCode oathTokenCode = OathTokenCode('12345678', 1000, 11000, TokenType.HOTP);

      // when
      when(authenticatorProvider.getOathTokenCode(hotpAccount.getOathMechanism().id)).thenAnswer((_) => completer.future);
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: AccountDetail(key: ValueKey<String>(hotpAccount.id), account: hotpAccount, isOTP: true),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      completer.complete(oathTokenCode);
      await eventFiring(tester);

      expect(find.text(formatCode(oathTokenCode)), findsOneWidget);
      expect(find.byIcon(Icons.change_circle_outlined), findsOneWidget);
      expect(find.byType(AnimatedCountDownTimer), findsNothing);

      // Test golden
      await expectLater(find.byType(AccountDetail),
          matchesGoldenFile('goldens/account-detail-widget/test-03-hotp-8-digits-account.png'));
    });

    testWidgets('Test 4 :: Display TOTP details correctly', (WidgetTester tester) async {
      // given
      final Account totpAccount = SampleData.createIndexedAccount(1);
      final Completer<OathTokenCode> completer = Completer<OathTokenCode>();
      final OathTokenCode oathTokenCode = OathTokenCode('111111', 10000, 20000, TokenType.TOTP);

      // when
      when(authenticatorProvider.getOathTokenCode(totpAccount.getOathMechanism().id)).thenAnswer((_) => completer.future);
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: AccountDetail(key: ValueKey<String>(totpAccount.id), account: totpAccount, isOTP: true),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      completer.complete(oathTokenCode);
      await eventFiring(tester);

      expect(find.text(formatCode(oathTokenCode)), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsNothing);
      expect(find.byType(AnimatedCountDownTimer), findsOneWidget);

      // Test golden
      await expectLater(find.byType(AccountDetail),
          matchesGoldenFile('goldens/account-detail-widget/test-04-totp-account-details-defaults.png'));
    });

  });
}
