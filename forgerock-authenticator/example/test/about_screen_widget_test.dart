/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forgerock_authenticator_example/screens/about_screen.dart';
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

void main() {
  setUp(() {
    return Future<void>(() async {
      await loadAppFonts();
    });
  });

  group('Testing AboutScreen UI', () {

    testWidgets('Test 01 :: About Screen UI', (WidgetTester tester) async {

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetForTestingWithProviders(
            child: const AboutScreen()
        ));
        await tester.pump();

        const AssetImage frLogoColor = AssetImage(
            'assets/images/fr-logo-color.png'
        );

        // precache images
        final Element imageAssetFirst = find.byType(Image).evaluate().first;
        await precacheImage(frLogoColor, imageAssetFirst);
        await tester.pumpAndSettle();
      });

      // Make sure that all expected elements are present in the About screen
      expect(find.text('About'), findsNWidgets(2)); // One in the header, one in the body
      expect(find.text('ForgeRock Authenticator'), findsOneWidget);
      expect(find.textContaining ('Version'), findsOneWidget);
      expect(find.textContaining('ForgeRock Authenticator works with the ForgeRock Identity Platform to deliver secure and easy access to apps and services.'), findsOneWidget);
      expect(find.text('Rate us'), findsOneWidget);
      expect(find.text('Leave a review in the Apple App Store'), findsOneWidget);
      expect(find.byKey(const Key('fr-logo-color.png')), findsOneWidget);

      // Test golden
      await expectLater(find.byType(AboutScreen),
          matchesGoldenFile('goldens/about-screen/about-screen-ui.png'));
    });

    testWidgets('Test 01 :: About Screen look and feel with different screen sizes', (WidgetTester tester) async {
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

        await tester.runAsync(() async {
          await tester.pumpWidget(createWidgetForTestingWithProviders(
              child: const AboutScreen()
          ));
          await tester.pump();

          // precache image-empty image
          final Element elementImageFRLogo = find.byKey(const Key('fr-logo-color.png')).evaluate().first;
          final Image elementImageFRLogoWidget = elementImageFRLogo.widget as Image;
          await precacheImage(elementImageFRLogoWidget.image, elementImageFRLogo);
          await tester.pumpAndSettle();
        });

        await expectLater(find.byType(AboutScreen),
            matchesGoldenFile(
                'goldens/about-screen/about-screen(${fakeDevices[i].model}-${fakeDevices[i].width.toInt()}x${fakeDevices[i].height.toInt()}).png'));
      }
    });
  });
}
