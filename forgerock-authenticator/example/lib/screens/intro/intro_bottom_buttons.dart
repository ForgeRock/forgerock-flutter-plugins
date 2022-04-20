/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';

import '../home_screen.dart';

class IntroBottomButtons extends StatelessWidget {

  const IntroBottomButtons(
      {Key key, this.currentIndex, this.dataLength, this.controller, this.rootContext})
      : super(key: key);

  final int currentIndex;
  final int dataLength;
  final PageController controller;
  final BuildContext rootContext;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
      currentIndex == dataLength - 1
          ? <Widget>[
              Container(),
              getStartedButton(context),
            ]
          : <Widget>[
              skipButton(context),
              nextButton(context),
            ],
    );
  }

  Widget getStartedButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        _completeIntro(rootContext, false);
      },
      child: TextScale(child: Text(
        AppLocalizations.of(context).introScreenGetStartedButton,
        style: TextStyle(
            fontSize: MediaQuery.of(context).size.height > 800 ? 18 : 16,
            height: 1.3, color: Colors.black,
            fontWeight: FontWeight.w300),
      )),
    );
  }

  Widget skipButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        _completeIntro(rootContext, true);
      },
      child: TextScale(child: Text(
        AppLocalizations.of(context).introScreenSkipButton,
        style: TextStyle(
            fontSize: MediaQuery.of(context).size.height > 800 ? 18 : 16,
            height: 1.3, color: Colors.black,
            fontWeight: FontWeight.w200),
      )),
    );
  }

  Widget nextButton(BuildContext context) {
    return Row(
      children: <Widget>[
        TextButton(
          onPressed: () {
            controller.nextPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut);
          },
          child: TextScale(child: Text(
            AppLocalizations.of(context).introScreenNextButton,
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.height > 800 ? 18 : 16,
                color: Colors.black,
                fontWeight: FontWeight.w300),
          )),
        ),
      ],
    );
  }

}

void _completeIntro(BuildContext context, bool skip) {
  SettingsProvider.setIntroDone(true);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute<HomeScreen>(builder: (BuildContext context) => const HomeScreen()),
  );
}