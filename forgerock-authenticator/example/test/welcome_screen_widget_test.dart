/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forgerock_authenticator_example/screens/intro/intro_screen.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'src/fake_device.dart';
import 'src/test_util.dart';

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

final List<FakeDevice> fakeDevices = <FakeDevice>[
  FakeDevice.iPhoneXR,
  FakeDevice.iPadMini2,
  FakeDevice.googlePixel,
  FakeDevice.googlePixel4,
  FakeDevice.samsungGalaxyS7
];

void main() {
  setUp(() {
    return Future<void>(() async {
      await loadAppFonts();
    });
  });

  group('Testing WelcomeScreen UI', () {

    testWidgets('Test 01 :: Welcome Screen (Welcome) UI', (WidgetTester tester) async {

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetForTestingWithProviders(
            child: const IntroScreen()
        ));
        await tester.pump();

        const AssetImage frLogoWhite = AssetImage(
            'assets/images/fr-icon-welcome.png'
        );

        // precache images
        final Element imageAssetFirst = find.byType(Image).evaluate().first;
        await precacheImage(frLogoWhite, imageAssetFirst);
        await tester.pumpAndSettle();
      });

      // Make sure that all expected elements are present
      expect(find.text('Welcome!'), findsNWidgets(1));
      expect(find.text('The ForgeRock Authenticator confirms your identity with your organization or service provider.'), findsOneWidget);

      // Test golden
      await expectLater(find.byType(IntroScreen),
          matchesGoldenFile('goldens/welcome-screen/welcome-screen-01.png'));

      for(int i = 0; i < fakeDevices.length; i++) {
        await tester.setScreenSize(width: fakeDevices[i].width, height: fakeDevices[i].height);
        await tester.pumpAndSettle();
        await expectLater(find.byType(IntroScreen),
            matchesGoldenFile(
                'goldens/welcome-screen/welcome-screen-01(${fakeDevices[i].model}-${fakeDevices[i].width.toInt()}x${fakeDevices[i].height.toInt()}).png'));
      }
    });

    testWidgets('Test 02 :: Welcome Screen (Add accounts) UI', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetForTestingWithProviders(
            child: const IntroScreen()
        ));
        await tester.pump();

        const AssetImage frLogoWhite = AssetImage(
            'assets/images/fr-icon-add-accounts.png'
        );
        // precache images
        final Element imageAssetFirst = find.byType(Image).evaluate().first;
        await precacheImage(frLogoWhite, imageAssetFirst);
        await tester.pumpAndSettle();
      });

      await tester.drag(find.byType(IntroScreen), const Offset(-500.0, 0.0));

      // Build the widget until the dismiss animation ends.
      await tester.pumpAndSettle();

      // Make sure that all expected elements are present
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('To add multiple accounts, use QR codes. The app and the ForgeRock Identity Platform support all One-Time Passwords types and Push Authentication.'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Test golden
      await expectLater(find.byType(IntroScreen),
          matchesGoldenFile('goldens/welcome-screen/welcome-screen-02.png'));

      for(int i = 0; i < fakeDevices.length; i++) {
        await tester.setScreenSize(width: fakeDevices[i].width, height: fakeDevices[i].height);
        await tester.pumpAndSettle();
        await expectLater(find.byType(IntroScreen),
            matchesGoldenFile(
                'goldens/welcome-screen/welcome-screen-02(${fakeDevices[i].model}-${fakeDevices[i].width.toInt()}x${fakeDevices[i].height.toInt()}).png'));
      }
    });

    testWidgets('Test 03 :: Welcome Screen (Biometric) UI', (WidgetTester tester) async {

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetForTestingWithProviders(
            child: const IntroScreen()
        ));
        await tester.pump();

        const AssetImage frLogoWhite = AssetImage(
            'assets/images/fr-icon-biometric.png'
        );

        // precache images
        final Element imageAssetFirst = find.byType(Image).evaluate().first;
        await precacheImage(frLogoWhite, imageAssetFirst);
        await tester.pumpAndSettle();
      });

      await tester.drag(find.byType(IntroScreen), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(IntroScreen), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();


      // Make sure that all expected elements are present
      expect(find.text('Biometric'), findsOneWidget);
      expect(find.text('To use extra security to unlock the app, enable Biometric authentication.'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      // Test golden
      await expectLater(find.byType(IntroScreen),
          matchesGoldenFile('goldens/welcome-screen/welcome-screen-03.png'));

      for(int i = 0; i < fakeDevices.length; i++) {
        await tester.setScreenSize(width: fakeDevices[i].width, height: fakeDevices[i].height);
        await tester.pumpAndSettle();
        await expectLater(find.byType(IntroScreen),
            matchesGoldenFile(
                'goldens/welcome-screen/welcome-screen-03(${fakeDevices[i].model}-${fakeDevices[i].width.toInt()}x${fakeDevices[i].height.toInt()}).png'));
      }
    });

    testWidgets('Test 04 :: Welcome Screen (Backup) UI', (WidgetTester tester) async {

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetForTestingWithProviders(
            child: const IntroScreen()
        ));
        await tester.pump();

        const AssetImage frIconWatch = AssetImage(
            'assets/images/fr-icon-watch.png'
        );

        // precache images
        final Element imageAssetFirst = find.byType(Image).evaluate().first;
        await precacheImage(frIconWatch, imageAssetFirst);
        await tester.pumpAndSettle();
      });

      await tester.drag(find.byType(IntroScreen), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(IntroScreen), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(IntroScreen), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      // Make sure that all expected elements are present
      expect(find.text('Watch'), findsOneWidget);
      expect(find.text('Approve or deny the login request using your Apple Watch.'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
      expect(find.text('Next'), findsNothing);
      expect(find.text('Done'), findsOneWidget);

      // Test golden
      await expectLater(find.byType(IntroScreen),
          matchesGoldenFile('goldens/welcome-screen/welcome-screen-04.png'));

      for(int i = 0; i < fakeDevices.length; i++) {
        await tester.setScreenSize(width: fakeDevices[i].width, height: fakeDevices[i].height);
        await tester.pumpAndSettle();
        await expectLater(find.byType(IntroScreen),
            matchesGoldenFile(
                'goldens/welcome-screen/welcome-screen-04(${fakeDevices[i].model}-${fakeDevices[i].width.toInt()}x${fakeDevices[i].height.toInt()}).png'));
      }
    });
  });
}
