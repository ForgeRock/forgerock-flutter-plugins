/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator_example/helpers/device_info_helper.dart';
import 'package:forgerock_authenticator_example/util/strings_util.dart';
import 'package:forgerock_authenticator_example/widgets/app_bar.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';

import '../util/browser_util.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ForgeRockAppBar(
        title: AppLocalizations.of(context).aboutScreenTitle,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextScale(child: Text(
                AppLocalizations.of(context).aboutScreenAppName,
                style: TextStyle(fontSize: 24, color: Colors.grey[700], fontWeight: FontWeight.w500),
                textAlign: TextAlign.left,
              )),
              TextScale(child: appVersion(context)),
              const SizedBox(height: 30),
              TextScale(child: Text(
                AppLocalizations.of(context).aboutScreenAboutTitle,
                style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w700),
                textAlign: TextAlign.left,
              )),
              const SizedBox(height: 10),
              TextScale(child: Text(
                AppLocalizations.of(context).aboutScreenAboutDescription,
                style: TextStyle(fontSize: 17, color: Colors.grey[900], fontWeight: FontWeight.w400),
                textAlign: TextAlign.left,
              )),
              const SizedBox(height: 30),
              Card(
                elevation: 0,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      // ListTile(
                      //   visualDensity: const VisualDensity(horizontal: -4, vertical: -3),
                      //   leading: const Icon(Icons.library_books),
                      //   title: TextScale(child: Text(AppLocalizations.of(context).aboutScreenThirdPartyLicenseTitle,
                      //     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),)
                      //   ),
                      //   subtitle: TextScale(child:
                      //     Text(
                      //         AppLocalizations.of(context).aboutScreenThirdPartyLicenseDescription,
                      //         style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.8))
                      //     )
                      //   ),
                      //   onTap: () {
                      //     launchInBrowser('https://www.forgerock.com/authenticator/third-party');
                      //   },
                      // ),
                      // const SizedBox(height: 10),
                      // ListTile(
                      //   visualDensity: const VisualDensity(horizontal: -4, vertical: -3),
                      //   leading: const Icon(Icons.library_books),
                      //   title: TextScale(child: Text(AppLocalizations.of(context).aboutScreenTermsAndConditionsTitle,
                      //       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                      //   subtitle: TextScale(child:
                      //   Text(
                      //       AppLocalizations.of(context).aboutScreenTermsAndConditionsDescription,
                      //       style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.8))
                      //   ),
                      //   ),
                      //   onTap: () {
                      //     launchInBrowser('https://www.forgerock.com/terms');
                      //   },
                      // ),
                      // const SizedBox(height: 10),
                      ListTile(
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -3),
                        leading: const Icon(Icons.library_books),
                        title: TextScale(child: Text(AppLocalizations.of(context).aboutScreenLicenseAgreementTitle,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                        subtitle: TextScale(child:
                        Text(
                            AppLocalizations.of(context).aboutScreenLicenseAgreementDescription,
                            style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.8))
                        ),
                        ),
                        onTap: () {
                          Platform.isAndroid
                              ? launchInBrowser('https://backstage.forgerock.com/knowledge/kb/book/b15463777#a82615872')
                              : launchInBrowser('https://backstage.forgerock.com/knowledge/kb/book/b15463777#a65593585');
                        },
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -3),
                        leading: const Icon(Icons.star_half),
                        title: TextScale(child: Text(AppLocalizations.of(context).aboutScreenRateTitle,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                        subtitle: TextScale(child:
                        Text(
                          Platform.isAndroid
                              ? AppLocalizations.of(context).aboutScreenRateDescriptionAndroid
                              : AppLocalizations.of(context).aboutScreenRateDescriptionIOS,
                          style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.8))
                        ),
                        ),
                        onTap: () {
                          Platform.isAndroid
                              ? launchInBrowser('https://play.google.com/store/apps/details?id=com.forgerock.authenticator')
                              : launchInBrowser('https://apps.apple.com/us/app/forgerock-authenticator/id1038442926');
                        },
                      ),
                    ])
              ),
              const Spacer(),
              Expanded(
                flex: 1,
                child: Center(
                  child: Column(children: <Widget>[
                    Image.asset(
                      'assets/images/fr-logo-color.png',
                      key: const Key('fr-logo-color.png'),
                      fit: BoxFit.fill,
                      alignment: Alignment.center,
                      height: 36,
                    ),
                    const SizedBox(height: 15),
                    TextScale(
                      maxFactor: 1.2,
                      child: Text(
                          copyrightForgerock(),
                          style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6)
                        )
                      )
                    )
                  ]),
                )
              ),
            ],
        )
      ),
    ));
  }

  Widget appVersion(BuildContext context) {
    return FutureBuilder<String>(
        future: DeviceInfoHelper.getAppVersion(),
        initialData: 'Unknown',
        builder: (BuildContext context, AsyncSnapshot<String> text) {
          return Text('${AppLocalizations.of(context).aboutScreenVersion} ${text.data}',
              style: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.w700));
        });
  }

}