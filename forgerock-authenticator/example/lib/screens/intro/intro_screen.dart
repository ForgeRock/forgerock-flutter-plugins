/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator_example/widgets/page_switcher.dart';

import 'intro_bottom_buttons.dart';
import 'intro_page.dart';

class IntroScreen extends StatefulWidget {

  const IntroScreen({Key key}) : super(key: key);

  static const String id = 'IntroScreen';

  @override
  IntroScreenState createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();

  int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        final List<PageData> data = getPageDataList(context);
        return Stack(
          children: <Widget>[
            Positioned(
              child: Align(
                alignment: FractionalOffset.center,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: data[_currentIndex].backgroundColor,
                  alignment: Alignment.center,
                  child: Container(
                    alignment: Alignment.center,
                    child:
                    PageView(
                      scrollDirection: Axis.horizontal,
                      controller: _controller,
                      onPageChanged: (int value) {
                        setState(() {
                          _currentIndex = value;
                        });
                      },
                      children: data
                          .map((PageData e) => IntroPage(data: e))
                          .toList()
                    )
                  ),
                ),
              )
            ),
            Positioned(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 65,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                            margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List<Widget>.generate(data.length,
                                      (int index) => PageSwitcher(
                                          index: index,
                                          currentIndex: _currentIndex
                                      )
                              ),
                            )
                        ),
                        IntroBottomButtons(
                          currentIndex: _currentIndex,
                          dataLength: data.length,
                          controller: _controller,
                          rootContext: context,
                        )
                      ],
                    )
                  ),
                ),
              ),
            ),
          ],
        );
      })
    );
  }

}

List<PageData> getPageDataList(BuildContext context) {
  const Color backgroundColor = Color(0xffF6F5F8);
  return <PageData>[
    PageData(
        description: AppLocalizations.of(context).introScreenPage1Description,
        title: AppLocalizations.of(context).introScreenPage1Header,
        image: 'assets/images/fr-icon-welcome.png',
        backgroundColor: backgroundColor),
    PageData(
        description: AppLocalizations.of(context).introScreenPage2Description,
        title: AppLocalizations.of(context).introScreenPage2Header,
        image: 'assets/images/fr-icon-add-accounts.png',
        backgroundColor: backgroundColor),
    PageData(
        description: AppLocalizations.of(context).introScreenPage3Description,
        title: AppLocalizations.of(context).introScreenPage3Header,
        image: 'assets/images/fr-icon-biometric.png',
        backgroundColor: backgroundColor),
    PageData(
        description: AppLocalizations.of(context).introScreenPage4Description,
        title: AppLocalizations.of(context).introScreenPage4Header,
        image: 'assets/images/fr-icon-watch.png',
        backgroundColor: backgroundColor),
  ];
}
