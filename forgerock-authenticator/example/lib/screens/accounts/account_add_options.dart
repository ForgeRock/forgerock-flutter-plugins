/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator_example/helpers/diagnostic_logger.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/screens/qrcode_scan_screen.dart';
import 'package:forgerock_authenticator_example/widgets/alert.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';
import 'package:provider/provider.dart';

import 'account_add_form.dart';

class AddAccountOptions extends StatelessWidget {

  const AddAccountOptions({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  blurRadius: 0.2, color: Colors.grey[300], spreadRadius: 0.1
              )
            ]),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                      child: TextScale(
                          child: Text(
                        AppLocalizations.of(context).addAccountFormTitle,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height > 800
                                ? 18
                                : 16,
                            height: 1.3,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ))),
                  InkWell(
                    onTap: () {
                        Navigator.pop(context);
                      },
                    child: Align(
                      alignment: Alignment.topRight,
                      child: CircleAvatar(
                        radius: 14.0,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(Icons.close, color: Colors.black),
                      ),
                    )
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10), bottom: Radius.circular(10)),
                  ),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        key: const Key('add-account-qr-code-scanner'),
                        trailing: const Icon(Icons.qr_code_scanner),
                        iconColor: Colors.black,
                        title: TextScale(
                            child: Text(
                                AppLocalizations.of(context).addAccountQrCode)),
                        onTap: () {
                          Navigator.pop(context);
                          _addAccountQrCode(context);
                        },
                      ),
                      const Divider(
                        height: 0.5,
                      ),
                      ListTile(
                        key: const Key('add-account-manually'),
                        trailing: const Icon(Icons.edit_outlined),
                        iconColor: Colors.black,
                        title: TextScale(
                            child: Text(
                                AppLocalizations.of(context).addAccountManual)),
                        onTap: () {
                          Navigator.pop(context);
                          _addAccountManually(context);
                        },
                      ),
                    ],
                  ))
            ],
          ),
        ));
  }
}

Future<void> _addAccountQrCode(BuildContext context) async {
  final BuildContext rootContext =
      context.findRootAncestorStateOfType<NavigatorState>().context;

  Future<void>.delayed(Duration.zero, () async {
    final String qrResult = await Navigator.push(
      context,
      MaterialPageRoute<String>(builder: (BuildContext context) => const QRCodeScanScreen()),
    );

    if (qrResult != null) {
      Provider.of<AuthenticatorProvider>(rootContext, listen: false)
          .addAccount(qrResult)
          .catchError((Object error) {
        DiagnosticLogger.severe('Error creating account via QRCode', error);
        alert(rootContext, AppLocalizations.of(rootContext).errorTitle,
            error.toString());
      });
    }
  });
}

Future<void> _addAccountManually(BuildContext context) async {
  showModalBottomSheet<AddAccountOptions>(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            color: const Color(0xFF737373),
            child: Container(
                height: 640,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Colors.white,
                ),
                child: const AccountAdd()),
          ),
        );
      });
}

void showAddAccountResult(BuildContext context, bool success) {
  final SnackBar snackBar = SnackBar(
    content: success
        ? TextScale(
            child: Text(
                AppLocalizations.of(context).addAccountFormRegistrationSucceed))
        : TextScale(
            child: Text(AppLocalizations.of(context)
                .addAccountFormRegistrationFailure)),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
