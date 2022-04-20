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
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:forgerock_authenticator_example/screens/edit_accounts/account_card_edit.dart';
import 'package:forgerock_authenticator_example/screens/edit_accounts/account_delete.dart';
import 'package:forgerock_authenticator_example/screens/edit_accounts/account_edit_form.dart';
import 'package:forgerock_authenticator_example/widgets/account_logo.dart';
import 'package:forgerock_authenticator_example/widgets/account_square_avatar.dart';
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
   *  - reorderIcon icon
   *  - accountLogo
   *  - accountName
   *  - editButton
   *  - deleteButton
   */

  group('Testing AccountCardEdit widget', () {

    testWidgets('Test 1 :: AccountCardEdit Look and Feel', (WidgetTester tester) async {
      /// Ensure that all expected UI elements are present in the AccountCardEdit widget
      // given
      final Account totpAccount = SampleData.createIndexedAccount(1);

      // when
      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: AccountCardEdit(key: ValueKey<String>(totpAccount.id), account: totpAccount),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));

      // then
      await eventFiring(tester);

      expect(find.byType(AccountCardEdit), findsOneWidget); // AccountCardEdit widget is present
      expect(find.byType(AccountLogo), findsOneWidget);  // AccountLogo is present
      expect(find.byType(AccountSquareAvatar), findsOneWidget);  // AccountSquareAvatar is present
      expect(find.descendant(of: find.byType(AccountSquareAvatar), matching: find.text('A')), findsOneWidget); // AccountSquareAvatar contains the inital letter of the issuer
      expect(find.text(totpAccount.issuer), findsOneWidget); // issuer name is present
      expect(find.text(totpAccount.accountName), findsOneWidget); // account name is present
      expect(find.descendant(of: find.byType(AccountCardEdit), matching: find.byIcon(Icons.edit)), findsOneWidget); // edit account icon is present
      expect(find.descendant(of: find.byType(AccountCardEdit), matching: find.byIcon(Icons.delete)), findsOneWidget); // delete account icon is present
      expect(find.descendant(of: find.byType(AccountCardEdit), matching: find.byIcon(Icons.drag_indicator)), findsOneWidget); // reorder icon is present

      // Test golden
      await expectLater(find.byType(AccountCardEdit),
          matchesGoldenFile('goldens/account-card-edit-widget/test-01-account-card-edit-look-and-feel.png'));
    });

    testWidgets('Test 2 :: Account Edit Wdiget tests', (WidgetTester tester) async {
      // given
      final Account totpAccount = SampleData.createIndexedAccount(1);
      final List<Account> mockAccountList = <Account>[
        totpAccount
      ];

      // when
      when(authenticatorProvider.accounts).thenAnswer((_) => mockAccountList);

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: AccountCardEdit(key: ValueKey<String>(totpAccount.id), account: totpAccount),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));

      // then
      await eventFiring(tester);

      // tap on the edit account icon
      await tester.tap(find.byIcon(Icons.edit));
      await eventFiring(tester);
      await tester.pumpAndSettle();

      // Make sure that the AccountEdit widget contains all UI elements
      expect(find.byType(AccountEdit), findsOneWidget); // One AccountEdit widget is what we expect here
      expect(find.descendant(of: find.byType(AccountEdit), matching: find.text('Edit Account')), findsOneWidget); // Title is present
      expect(find.descendant(of: find.byType(AccountEdit), matching: find.byType(TextFormField)), findsNWidgets(2)); // 2 text fields are present (Issuer and Account Name)
      expect(find.descendant(of: find.byType(AccountEdit), matching: find.byType(ElevatedButton)), findsOneWidget); // Save button is present

      final Finder issuerTextFieldFinder = find.byType(TextFormField).first;
      final Finder accountNameTextFinder = find.byType(TextFormField).last;
      final Finder saveButtonFinder = find.byType(ElevatedButton);

      final TextFormField issuerTextField = tester.firstWidget(issuerTextFieldFinder);
      final TextFormField accountNameTextField = tester.firstWidget(accountNameTextFinder);

      // Test the "Issuer" text field
      expect(issuerTextField.initialValue, totpAccount.issuer);

      // Test the "Account Name" text field
      expect(accountNameTextField.initialValue, totpAccount.accountName);

      // Check some basic properties of the "Save" button
      expect(tester.getSemantics(saveButtonFinder), matchesSemantics(
        label: 'Save Changes',
        isButton: true,
        hasTapAction: true,
        isEnabled: true,
        hasEnabledState: true,
        isFocusable: true,
      ));

      // Update issuer and account name:
      await tester.enterText(issuerTextFieldFinder, 'Updated Issuer');
      await tester.enterText(accountNameTextFinder, 'Updated Account Name');
      await tester.pumpAndSettle();

      await expectLater(find.byType(AccountEdit),
          matchesGoldenFile('goldens/account-card-edit-widget/test-02-account-edit-widget.png'));

      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      // Clicking on the save button will return the user the Account Card Edit widget:
      expect(find.byType(AccountCardEdit), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('Test 3 :: Delete Account Wdiget tests', (WidgetTester tester) async {
      // given
      final Account totpAccount = SampleData.createIndexedAccount(1);
      final List<Account> mockAccountList = <Account>[
        totpAccount
      ];

      // when
      when(authenticatorProvider.accounts).thenAnswer((_) => mockAccountList);

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: AccountCardEdit(key: ValueKey<String>(totpAccount.id), account: totpAccount),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));

      // then
      await eventFiring(tester);

      // tap on the delete account icon
      await tester.tap(find.byIcon(Icons.delete));
      await eventFiring(tester);

      await tester.runAsync(() async {
        const AssetImage frIconDelete = AssetImage(
            'assets/images/fr-icon-delete-account.png'
        );

        // precache images
        final Element imageAssetFirst = find.byType(Image).evaluate().first;
        await precacheImage(frIconDelete, imageAssetFirst);
        await tester.pumpAndSettle();
      });

      await tester.pumpAndSettle();

      // Make sure that the AccountDelete widget contains all UI elements
      expect(find.byType(AccountDelete), findsOneWidget); // One AccountDelete widget is what we expect here
      expect(find.descendant
        (of: find.byType(AccountDelete),
          matching: find.byKey(const Key('fr-icon-delete-account'))),
          findsOneWidget); // Delete account image is present

      expect(find.descendant(of: find.byType(AccountDelete), matching: find.text('Delete Account')), findsOneWidget); // Title is present
      expect(find.descendant(of: find.byType(AccountDelete), matching: find.textContaining('Are you sure you want to remove this account?')), findsOneWidget); // warning message is present
      expect(find.descendant(of: find.byType(AccountDelete), matching: find.byType(ElevatedButton)), findsNWidgets(2)); // Delete and Cancel button buttons are present
      expect(find.descendant(of: find.byType(ElevatedButton), matching: find.text('Delete')), findsOneWidget);
      expect(find.descendant(of: find.byType(ElevatedButton), matching: find.text('Cancel')), findsOneWidget);

      final Finder deleteButtonFinder = find.descendant(of: find.byType(ElevatedButton), matching: find.text('Delete'));

      await expectLater(find.byType(AccountDelete),
          matchesGoldenFile('goldens/account-card-edit-widget/test-03-account-delete-widget.png'));

      // Taping on the "delete" buttin dismisses the dialog
      await tester.tap(deleteButtonFinder);
      await tester.pumpAndSettle();

      // Clicking on the delete button will return the user the Account Card Edit widget:
      expect(find.byType(AccountDelete), findsNothing);
    });

    testWidgets('Test 4 :: Delete Account Wdiget tests (PUSH and OATH)', (WidgetTester tester) async {
      // given
      final Account account = SampleData.createIndexedAccount(1);

      // Add a PUSH mechanism to the account
      account.mechanismList.add(SampleData.createRandomMechanism(account.issuer, account.accountName, Mechanism.PUSH));

      final List<Account> mockAccountList = <Account>[
        account
      ];

      // when
      when(authenticatorProvider.accounts).thenAnswer((_) => mockAccountList);

      await tester.pumpWidget(createWidgetForTestingWithProviders(
          child: AccountCardEdit(key: ValueKey<String>(account.id), account: account),
          authenticatorProvider: authenticatorProvider,
          settingsProvider: settingsProvider
      ));

      // then
      await eventFiring(tester);

      await expectLater(find.byType(AccountCardEdit),
          matchesGoldenFile('goldens/account-card-edit-widget/test-04-account-card-edit-look-and-feel.png'));

      // tap on the delete account icon
      await tester.tap(find.byIcon(Icons.delete));
      await eventFiring(tester);

      await tester.runAsync(() async {
        const AssetImage frIconDelete = AssetImage(
            'assets/images/fr-icon-delete-account.png'
        );

        // precache images
        final Element imageAssetFirst = find.byType(Image).evaluate().first;
        await precacheImage(frIconDelete, imageAssetFirst);
        await tester.pumpAndSettle();
      });

      await tester.pumpAndSettle();

      // Make sure that the AccountDelete widget contains all UI elements
      expect(find.byType(AccountDelete), findsOneWidget); // One AccountDelete widget is what we expect here
      expect(find.descendant
        (of: find.byType(AccountDelete),
          matching: find.byKey(const Key('fr-icon-delete-account'))),
          findsOneWidget); // Delete account image is present

      expect(find.descendant(of: find.byType(AccountDelete), matching: find.text('Delete Account')), findsOneWidget); // Title is present
      expect(find.descendant(of: find.byType(AccountDelete), matching: find.textContaining('Are you sure you want to remove this account?')), findsOneWidget); // warning message is present
      expect(find.descendant(of: find.byType(AccountDelete), matching: find.byType(ElevatedButton)), findsNWidgets(4)); // Delete and Cancel button buttons are present
      expect(find.descendant(of: find.byType(ElevatedButton), matching: find.text('Delete Push')), findsOneWidget);
      expect(find.descendant(of: find.byType(ElevatedButton), matching: find.text('Delete OTP')), findsOneWidget);
      expect(find.descendant(of: find.byType(ElevatedButton), matching: find.text('Delete All')), findsOneWidget);
      expect(find.descendant(of: find.byType(ElevatedButton), matching: find.text('Cancel')), findsOneWidget);

      await expectLater(find.byType(AccountDelete),
          matchesGoldenFile('goldens/account-card-edit-widget/test-04-account-delete-widget-multi-mechanism.png'));
    });

  });
}
