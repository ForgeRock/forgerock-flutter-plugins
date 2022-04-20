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
import 'package:forgerock_authenticator_example/screens/edit_accounts/account_card_edit.dart';
import 'package:forgerock_authenticator_example/screens/edit_accounts/account_edit_form.dart';
import 'package:forgerock_authenticator_example/screens/edit_accounts/edit_accounts_screen.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';

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

  group('Test EditAccounts Screen', () {

    testWidgets('Test 01 :: EditAccountsScreen with 0 accounts', (WidgetTester tester) async {
      // given app with no data
      final List<Account> mockAccountList = <Account>[];
      final List<String> mockAccountListOrderIndex = <String>[];

      when(authenticatorProvider.getAllAccounts()).thenAnswer((_) => Future<List<Account>>.value(mockAccountList));
      when(authenticatorProvider.accounts).thenAnswer((_) => mockAccountList);
      when(authenticatorProvider.getAccountOrderIndex()).thenAnswer((_) => mockAccountListOrderIndex);

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetForTestingWithProviders(
            child: const EditAccountsScreen(),
            authenticatorProvider: authenticatorProvider,
            settingsProvider: settingsProvider
        ));
        await tester.pump();

        const AssetImage frNoAccounts = AssetImage(
            'assets/images/fr-icon-no-accounts.png'
        );
        // precache images
        final Element imageAssetFirst = find.byType(Image).evaluate().first;
        await precacheImage(frNoAccounts, imageAssetFirst);
        await tester.pumpAndSettle();
      });

      // then ensure all expected widgets are present
      expect(find.byType(AccountCardEdit), findsNothing);
      expect(find.text('Done'), findsOneWidget);

      // Test golden
      await expectLater(find.byType(EditAccountsScreen),
          matchesGoldenFile('goldens/edit-accounts-screen/test-01-no-accounts.png'));
    });

    testWidgets('Test 02 :: EditAccountsScreen with 3 accounts', (WidgetTester tester) async {
      // given
      // default mock accounts in MockAuthenticatorProvider (3 accounts)
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const EditAccountsScreen(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();
      // then
      expect(find.byType(AccountCardEdit), findsNWidgets(3));
      expect(find.text(authenticatorProvider.accounts.elementAt(0).issuer), findsOneWidget);
      expect(find.text(authenticatorProvider.accounts.elementAt(1).issuer), findsOneWidget);
      expect(find.text(authenticatorProvider.accounts.elementAt(2).issuer), findsOneWidget);

      // Test golden
      await expectLater(find.byType(EditAccountsScreen),
          matchesGoldenFile('goldens/edit-accounts-screen/test-02-edit-accounts-screen-with-3-accounts.png'));
    });

    testWidgets('Test 03 :: Reorder accounts', (WidgetTester tester) async {
      final List<Account> mockAccountList = <Account>[
        Account.fromJson(SampleData.account1Json as Map<String, dynamic>),
        SampleData.createIndexedAccount(2, Mechanism.OATH, TokenType.TOTP),
        SampleData.createIndexedAccount(3, Mechanism.OATH, TokenType.HOTP),
        SampleData.createIndexedAccount(4, Mechanism.PUSH),
        Account.fromJson(SampleData.account3Json as Map<String, dynamic>)
      ];

      final List<String> mockAccountListOrderIndex = <String>[
        mockAccountList.elementAt(0).id,
        mockAccountList.elementAt(1).id,
        mockAccountList.elementAt(2).id,
        mockAccountList.elementAt(3).id,
        mockAccountList.elementAt(4).id
      ];

      when(authenticatorProvider.accounts).thenAnswer((_) => mockAccountList);
      when(authenticatorProvider.getAccountOrderIndex()).thenAnswer((_) => mockAccountListOrderIndex);

      // given
      // default mock accounts in MockAuthenticatorProvider (3 accounts)
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const EditAccountsScreen(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();
      await expectLater(find.byType(EditAccountsScreen),
          matchesGoldenFile('goldens/edit-accounts-screen/test-03-reorder-accounts-initial.png'));

      // Make sure the order of the card is correct
      final Finder firstAccountEditCard = find.byType(AccountCardEdit).at(0);
      final Finder secondAccountEditCard = find.byType(AccountCardEdit).at(1);
      final Finder thirdAccountEditCard = find.byType(AccountCardEdit).at(2);
      final Finder forthAccountEditCard = find.byType(AccountCardEdit).at(3);
      final Finder lastAccountEditCard = find.byType(AccountCardEdit).at(4);

      AccountCardEdit firstCard = tester.firstWidget(firstAccountEditCard);
      AccountCardEdit secondCard = tester.firstWidget(secondAccountEditCard);
      AccountCardEdit thirdCard = tester.firstWidget(thirdAccountEditCard);
      AccountCardEdit forthCard = tester.firstWidget(forthAccountEditCard);
      AccountCardEdit lastCard = tester.firstWidget(lastAccountEditCard);

      expect(firstCard.account.id, mockAccountList.elementAt(0).id);
      expect(secondCard.account.id, mockAccountList.elementAt(1).id);
      expect(thirdCard.account.id, mockAccountList.elementAt(2).id);
      expect(forthCard.account.id, mockAccountList.elementAt(3).id);
      expect(lastCard.account.id, mockAccountList.elementAt(4).id);

      // Swap the first and the last cards...
      final TestGesture dragLastCard = await tester.startGesture(tester.getCenter(lastAccountEditCard));
      await tester.pump(const Duration(seconds: 3));
      Offset targetOffset = const Offset(13.0, 10.0);
      await dragLastCard.moveTo(targetOffset);
      await tester.pump();
      await dragLastCard.up();
      await tester.pumpAndSettle();

      // Test golden
      await expectLater(find.byType(EditAccountsScreen),
          matchesGoldenFile('goldens/edit-accounts-screen/test-03-reorder-accounts-reorder-step1.png'));

      // The initial first card is now second
      final TestGesture drag = await tester.startGesture(tester.getCenter(secondAccountEditCard));
      await tester.pump(const Duration(seconds: 3));
      targetOffset = const Offset(13.0, 600.0);
      await drag.moveTo(targetOffset);
      await tester.pump();
      await drag.up();
      await tester.pumpAndSettle();

      // Test golden
      await expectLater(find.byType(EditAccountsScreen),
          matchesGoldenFile('goldens/edit-accounts-screen/test-03-reorder-accounts-reorder-step2.png'));

      firstCard = tester.firstWidget(firstAccountEditCard);
      secondCard = tester.firstWidget(secondAccountEditCard);
      thirdCard = tester.firstWidget(thirdAccountEditCard);
      forthCard = tester.firstWidget(forthAccountEditCard);
      lastCard = tester.firstWidget(lastAccountEditCard);

      // Test the order again...
      expect(firstCard.account.id, mockAccountList.elementAt(4).id);
      expect(secondCard.account.id, mockAccountList.elementAt(1).id);
      expect(thirdCard.account.id, mockAccountList.elementAt(2).id);
      expect(forthCard.account.id, mockAccountList.elementAt(3).id);
      expect(lastCard.account.id, mockAccountList.elementAt(0).id);
    });

    testWidgets('Test 04 :: Delete accounts', (WidgetTester tester) async {

      final List<Account> mockAccountList = <Account>[
        Account.fromJson(SampleData.account1Json as Map<String, dynamic>),
        SampleData.createIndexedAccount(2, Mechanism.OATH, TokenType.TOTP),
        SampleData.createIndexedAccount(3, Mechanism.OATH, TokenType.HOTP),
        SampleData.createIndexedAccount(4, Mechanism.PUSH),
        Account.fromJson(SampleData.account3Json as Map<String, dynamic>)
      ];

      final List<String> mockAccountListOrderIndex = <String>[
        mockAccountList.elementAt(0).id,
        mockAccountList.elementAt(1).id,
        mockAccountList.elementAt(2).id,
        mockAccountList.elementAt(3).id,
        mockAccountList.elementAt(4).id
      ];

      when(authenticatorProvider.accounts).thenAnswer((_) => mockAccountList);
      when(authenticatorProvider.getAccountOrderIndex()).thenAnswer((_) => mockAccountListOrderIndex);

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const EditAccountsScreen(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();
      await expectLater(find.byType(EditAccountsScreen),
          matchesGoldenFile('goldens/edit-accounts-screen/test-04-delete-accounts-initial.png'));

      expect(find.byType(AccountCardEdit), findsNWidgets(5));

      // Delete the third and first accounts...
      await tester.tap(find.byIcon(Icons.delete).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete-button')));
      await tester.pumpAndSettle();

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const EditAccountsScreen(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      // Make sure that now the EditAccountsScreen contains only 3 AccountCardEdit.
      expect(find.byType(AccountCardEdit), findsNWidgets(3));

      final Finder firstAccountEditCard = find.byType(AccountCardEdit).at(0);
      final Finder secondAccountEditCard = find.byType(AccountCardEdit).at(1);
      final Finder thirdAccountEditCard = find.byType(AccountCardEdit).at(2);

      final AccountCardEdit firstCard = tester.firstWidget(firstAccountEditCard);
      final AccountCardEdit secondCard = tester.firstWidget(secondAccountEditCard);
      final AccountCardEdit thirdCard = tester.firstWidget(thirdAccountEditCard);

      expect(firstCard.account.issuer, 'ACCOUNT-ISSUER-002');
      expect(secondCard.account.issuer, 'ACCOUNT-ISSUER-004');
      expect(thirdCard.account.issuer, 'issuer3');

      await expectLater(find.byType(EditAccountsScreen),
          matchesGoldenFile('goldens/edit-accounts-screen/test-04-delete-accounts-result.png'));
    });

    testWidgets('Test 05 :: Update accounts', (WidgetTester tester) async {

      final List<Account> mockAccountList = <Account>[
        Account.fromJson(SampleData.account1Json as Map<String, dynamic>),
        SampleData.createIndexedAccount(2, Mechanism.OATH, TokenType.TOTP),
        SampleData.createIndexedAccount(3, Mechanism.OATH, TokenType.HOTP),
        SampleData.createIndexedAccount(4, Mechanism.PUSH),
        Account.fromJson(SampleData.account3Json as Map<String, dynamic>)
      ];

      final List<String> mockAccountListOrderIndex = <String>[
        mockAccountList.elementAt(0).id,
        mockAccountList.elementAt(1).id,
        mockAccountList.elementAt(2).id,
        mockAccountList.elementAt(3).id,
        mockAccountList.elementAt(4).id
      ];

      when(authenticatorProvider.accounts).thenAnswer((_) => mockAccountList);
      when(authenticatorProvider.getAccountOrderIndex()).thenAnswer((_) => mockAccountListOrderIndex);

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const EditAccountsScreen(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      // Update the first account...
      await tester.tap(find.byIcon(Icons.edit).at(0));
      await tester.pumpAndSettle();

      expect(find.byType(AccountEdit), findsOneWidget); // One AccountEdit widget is what we expect here
      final Finder issuerTextFieldFinder = find.byType(TextField).first;
      final Finder accountNameTextFinder = find.byType(TextField).last;
      final Finder saveButtonFinder = find.byType(ElevatedButton);

      // Update issuer and account name:
      await tester.enterText(issuerTextFieldFinder, 'Updated Issuer 1');
      await tester.enterText(accountNameTextFinder, 'Updated Account Name 1');
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      // Update the second account...
      await tester.tap(find.byIcon(Icons.edit).at(1));
      await tester.pumpAndSettle();

      expect(find.byType(AccountEdit), findsOneWidget); // One AccountEdit widget is what we expect here
      // Attempt to rename issuer and account name with empty string...
      await tester.enterText(issuerTextFieldFinder, '');
      await tester.enterText(accountNameTextFinder, '');
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: const EditAccountsScreen(),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));
      await tester.pumpAndSettle();

      final Finder firstAccountEditCard = find.byType(AccountCardEdit).at(0);
      final Finder secondAccountEditCard = find.byType(AccountCardEdit).at(1);
      final Finder thirdAccountEditCard = find.byType(AccountCardEdit).at(2);
      final Finder forthAccountEditCard = find.byType(AccountCardEdit).at(3);
      final Finder lastAccountEditCard = find.byType(AccountCardEdit).at(4);

      expect(find.descendant(of: firstAccountEditCard, matching: find.text('Updated Issuer 1')), findsOneWidget);
      expect(find.descendant(of: firstAccountEditCard, matching: find.text('Updated Account Name 1')), findsOneWidget);
      expect(find.descendant(of: secondAccountEditCard, matching: find.text('ACCOUNT-ISSUER-002')), findsOneWidget);
      expect(find.descendant(of: secondAccountEditCard, matching: find.text('ACCOUNT-NAME-002')), findsOneWidget);
      expect(find.descendant(of: thirdAccountEditCard, matching: find.text('ACCOUNT-ISSUER-003')), findsOneWidget);
      expect(find.descendant(of: thirdAccountEditCard, matching: find.text('ACCOUNT-NAME-003')), findsOneWidget);
      expect(find.descendant(of: forthAccountEditCard, matching: find.text('ACCOUNT-ISSUER-004')), findsOneWidget);
      expect(find.descendant(of: forthAccountEditCard, matching: find.text('ACCOUNT-NAME-004')), findsOneWidget);
      expect(find.descendant(of: lastAccountEditCard, matching: find.text('issuer3')), findsOneWidget);
      expect(find.descendant(of: lastAccountEditCard, matching: find.text('user3')), findsOneWidget);

      await expectLater(find.byType(EditAccountsScreen),
          matchesGoldenFile('goldens/edit-accounts-screen/test-05-updated-accounts-result.png'));
    });

  });
}
