/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator/models/mechanism.dart';
import 'package:forgerock_authenticator/models/oath_mechanism.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:forgerock_authenticator_example/screens/accounts/account_card.dart';
import 'package:forgerock_authenticator_example/screens/accounts/account_list.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';

import 'src/fake_device.dart';
import 'src/mock_authenticator_provider.dart';
import 'src/mock_settings_provider.dart';
import 'src/sample_data.dart';
import 'src/test_util.dart';

AuthenticatorProvider authenticatorProvider;
SettingsProvider settingsProvider;

extension SetScreenSize on WidgetTester {
  Future<void> setScreenSize(
      {double width = 540,
        double height = 960,
        double pixelDensity = 1}) async {
    final Size size = Size(width, height);
    await binding.setSurfaceSize(size);
    binding.window.physicalSizeTestValue = size;
    binding.window.devicePixelRatioTestValue = pixelDensity;
  }
}

void main() {
  setUp(() {
    return Future<void>(() async {
      authenticatorProvider = createMockAuthenticatorProvider();
      settingsProvider = createMockSettingsProvider();
      await loadAppFonts();
    });
  });

  group('Testing AuthenticatorApp widget for different scenarios', () {

    testWidgets('Test 01 :: AccountList with NO accounts', (WidgetTester tester) async {
      // given app with no data
      final List<Account> mockAccountList = <Account>[];
      when(authenticatorProvider.getAllAccounts()).thenAnswer((_) => Future<List<Account>>.value(mockAccountList));
      when(authenticatorProvider.accounts).thenAnswer((_) => mockAccountList);

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetForTestingWithProviders(
            child: const AccountList(),
            authenticatorProvider: authenticatorProvider,
            settingsProvider: settingsProvider
        ));
        await tester.pump();

        const AssetImage frNoAccountsImage = AssetImage(
            'assets/images/fr-icon-no-accounts.png'
        );

        // precache images
        final Element imageAssetFirst = find.byType(Image).evaluate().first;
        await precacheImage(frNoAccountsImage, imageAssetFirst);
        await tester.pumpAndSettle();
      });

      expect(find.text('No accounts'), findsOneWidget);
      expect(find.text('Register your first account using the camera to scan a QR Code'), findsOneWidget);

      // Test golden
      await expectLater(find.byType(AccountList),
          matchesGoldenFile('goldens/account-list/test-01-account-list-no-accounts.png'));
    });

    testWidgets('Test 02 :: AccountList with one account', (WidgetTester tester) async {
      // given
      final List<Account> mockAccountList = <Account>[
        Account.fromJson(SampleData.account3Json as Map<String, dynamic>)
      ];

      final List<String> mockAccountListOrderIndex = <String>[
        Account.fromJson(SampleData.account3Json as Map<String, dynamic>).id
      ];

      // when
      when(authenticatorProvider.accounts).thenAnswer((_) => mockAccountList);
      when(authenticatorProvider.getAccountOrderIndex()).thenAnswer((_) => mockAccountListOrderIndex);

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const AccountList(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      // then
      expect(find.byType(AccountCard), findsOneWidget);
      expect(find.text(mockAccountList.first.issuer), findsOneWidget);
      expect(find.text(mockAccountList.first.accountName), findsOneWidget);

      // Test golden
      await expectLater(find.byType(AccountList),
          matchesGoldenFile('goldens/account-list/test-02-account-list-with-one-account-only.png'));
    });

    testWidgets('Test 03 :: AccountList with a 3 accounts', (WidgetTester tester) async {
      // given
      // default mock accounts in MockAuthenticatorProvider
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const AccountList(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();
      // then
      expect(find.byType(AccountCard), findsNWidgets(3));
      expect(find.text(authenticatorProvider.accounts.elementAt(0).issuer), findsOneWidget);
      expect(find.text(authenticatorProvider.accounts.elementAt(1).issuer), findsOneWidget);
      expect(find.text(authenticatorProvider.accounts.elementAt(2).issuer), findsOneWidget);

      // Test golden
      await expectLater(find.byType(AccountList),
          matchesGoldenFile('goldens/account-list/test-03-account-list-multiple-accounts.png'));
    });

    testWidgets('Test look and feel with different screen sizes', (WidgetTester tester) async {
      // Run on the following...
      final List<FakeDevice> fakeDevices = <FakeDevice>[
        FakeDevice.iPhoneXR,
        FakeDevice.iPadMini2,
        FakeDevice.googlePixel,
        FakeDevice.googlePixel4,
        FakeDevice.samsungGalaxyS7
      ];

      for(int i = 0; i < fakeDevices.length; i++) {
        await tester.setScreenSize(width: fakeDevices[i].width, height: fakeDevices[i].height);
        await tester.pumpWidget(createWidgetForTestingWithProviders(
            child: const AccountList(),
            authenticatorProvider: authenticatorProvider,
            settingsProvider: settingsProvider
        ));
        await tester.pumpAndSettle();
        await expectLater(find.byType(AccountList),
            matchesGoldenFile(
                'goldens/account-list/test-03-account-list-multiple-accounts(${fakeDevices[i].model}-${fakeDevices[i].width.toInt()}x${fakeDevices[i].height.toInt()}).png'));
      }
    }); // Test look and feel...

    testWidgets('Test 04 :: AccountList with long account name', (WidgetTester tester) async {
      // given
      const String id = 'ACCOUNT-ID-001';
      const String issuer = 'ACCOUNT-ISSUER-001';
      const String  accountName = 'VERY-VERY-VERY-VERY-VERY-VERY-VERY-VERY-VERY-VERY-VERY-VERY-LONG-ACCOUNT-NAME';
      final Account testAccount = Account.fromJson(SampleData.account3Json as Map<String, dynamic>);
      testAccount.id = id;
      testAccount.issuer = issuer;
      testAccount.accountName = accountName;

      final List<Account> mockAccountList = <Account>[
        testAccount
      ];
      final List<String> mockAccountListOrderIndex = <String>[
        testAccount.id
      ];

      // when
      when(authenticatorProvider.accounts).thenAnswer((_) => mockAccountList);
      when(authenticatorProvider.getAccountOrderIndex()).thenAnswer((_) => mockAccountListOrderIndex);
      await tester.setScreenSize(width: FakeDevice.googlePixel.width, height: FakeDevice.googlePixel.height);

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const AccountList(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      // then
      expect(find.byType(AccountCard), findsOneWidget);
      expect(find.text(mockAccountList.first.issuer), findsOneWidget);
      expect(find.text(mockAccountList.first.accountName), findsOneWidget);

      // Test golden
      await expectLater(find.byType(AccountList),
          matchesGoldenFile('goldens/account-list/test-04-account-list-long-account-name.png'));
    });

    testWidgets('Test 05 :: AccountList scrolling', (WidgetTester tester) async {
      // given
      final List<Account> mockAccountList = <Account>[
        Account.fromJson(SampleData.account1Json as Map<String, dynamic>),
        SampleData.createIndexedAccount(2, Mechanism.OATH, TokenType.TOTP),
        SampleData.createIndexedAccount(3, Mechanism.OATH, TokenType.HOTP),
        SampleData.createIndexedAccount(4, Mechanism.PUSH),
        SampleData.createIndexedAccount(5),
        SampleData.createIndexedAccount(6),
        SampleData.createIndexedAccount(7),
        SampleData.createIndexedAccount(8),
        SampleData.createIndexedAccount(9, Mechanism.PUSH),
        Account.fromJson(SampleData.account3Json as Map<String, dynamic>)
      ];

      final List<String> mockAccountListOrderIndex = <String>[
        mockAccountList.elementAt(0).id,
        mockAccountList.elementAt(1).id,
        mockAccountList.elementAt(2).id,
        mockAccountList.elementAt(3).id,
        mockAccountList.elementAt(4).id,
        mockAccountList.elementAt(5).id,
        mockAccountList.elementAt(6).id,
        mockAccountList.elementAt(7).id,
        mockAccountList.elementAt(8).id,
        mockAccountList.elementAt(9).id
      ];

      // when
      when(authenticatorProvider.accounts).thenAnswer((_) => mockAccountList);
      when(authenticatorProvider.getAccountOrderIndex()).thenAnswer((_) => mockAccountListOrderIndex);
      await tester.setScreenSize(width: FakeDevice.googlePixel.width, height: FakeDevice.googlePixel.height);

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const AccountList(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      // Test golden
      await expectLater(find.byType(AccountList),
          matchesGoldenFile('goldens/account-list/test-05-account-list-10-accounts-initial.png'));

      // On Pixel Phone only the first 5 accounts are visible
      expect(find.byType(AccountCard), findsNWidgets(5));

      // Make sure that the first account is visible and is at position 0
      expect(find.text(authenticatorProvider.accounts.elementAt(0).issuer), findsOneWidget);

      // Make sure that the last account is NOT visible
      expect(find.text(authenticatorProvider.accounts.elementAt(9).issuer), findsNothing);

      // Scroll to the bottom and ensure that we can see the last account...
      await tester.drag(find.byType(AccountList), const Offset(0, -1200));
      await tester.pumpAndSettle();

      // Make sure that the first account is NOT visible after scrolling
      expect(find.text(authenticatorProvider.accounts.elementAt(0).issuer), findsNothing);

      // Make sure that the last account is now visible
      expect(find.text(authenticatorProvider.accounts.elementAt(9).issuer), findsOneWidget);

      // Test golden
      await expectLater(find.byType(AccountList),
          matchesGoldenFile('goldens/account-list/test-05-account-list-10-accounts-after-scroll.png'));
    });
  });
}
