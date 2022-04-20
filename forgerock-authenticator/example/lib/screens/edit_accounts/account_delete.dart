/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';
import 'package:provider/provider.dart';

class AccountDelete extends StatelessWidget {

  const AccountDelete({Key key, this.account}) : super(key: key);

  final Account account;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
              padding: const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/images/fr-icon-delete-account.png',
                    key: const Key('fr-icon-delete-account'),
                    fit: BoxFit.fill,
                    alignment: Alignment.center,
                    width: 50,
                    height: 60,
                  ),
                  const SizedBox(height: 10),
                  Center(child: TextScale(child: Text(
                      AppLocalizations.of(context).deleteAccountDialogTitle,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)))
                  ),
                  const SizedBox(height: 24),
                  TextScale(maxFactor: 1.2, child: Text(
                    AppLocalizations.of(context).deleteAccountDialogMessage,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  )),
                  const SizedBox(height: 24),
                  if (account.hasMultipleMechanisms()) multipleMechanisms(context) else singleMechanism(context),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      key: const Key('cancel-button'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        minimumSize: const Size.fromHeight(42),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      child: TextScale(child: Text(
                        AppLocalizations.of(context).deleteAccountDialogCancelButton,
                        style: const TextStyle(fontSize: 18),))
                  ),
                  const SizedBox(height: 20),
                ],
              )
          )
        ]
    );
  }

  Widget multipleMechanisms(BuildContext context) {
    return Column(
      children: <Widget>[
        ElevatedButton(
            key: const Key('delete-push-button'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              primary: const Color(0xFF006AC8),
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              minimumSize: const Size.fromHeight(42),
            ),
            onPressed: () async {
              Provider.of<AuthenticatorProvider>(context, listen: false)
                  .removeMechanism(account.getPushMechanism().mechanismUID);
              Navigator.of(context).pop();
            },
            child: TextScale(child: Text(
              AppLocalizations.of(context).deleteAccountDialogDeletePushButton,
              style: const TextStyle(fontSize: 18),
            ))
        ),
        const SizedBox(height: 10),
        ElevatedButton(
            key: const Key('delete-oath-button'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              primary: const Color(0xFF006AC8),
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              minimumSize: const Size.fromHeight(42),
            ),
            onPressed: () async {
              Provider.of<AuthenticatorProvider>(context, listen: false)
                  .removeMechanism(account.getOathMechanism().mechanismUID);
              Navigator.of(context).pop();
            },
            child: TextScale(child: Text(
              AppLocalizations.of(context).deleteAccountDialogDeleteOathButton,
              style: const TextStyle(fontSize: 18),
            ))
        ),
        const SizedBox(height: 10),
        ElevatedButton(
            key: const Key('delete-all-button'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              primary: const Color(0xFF006AC8),
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              minimumSize: const Size.fromHeight(42),
            ),
            onPressed: () async {
              Provider.of<AuthenticatorProvider>(context, listen: false)
                  .removeAccount(account.id);
              Navigator.of(context).pop();
            },
            child: TextScale(child: Text(
              AppLocalizations.of(context).deleteAccountDialogDeleteAllButton,
              style: const TextStyle(fontSize: 18),
            ))
        )
      ],
    );
  }

  Widget singleMechanism(BuildContext context) {
    return ElevatedButton(
        key: const Key('delete-button'),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          primary: const Color(0xFF006AC8),
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)),
          minimumSize: const Size.fromHeight(42),
        ),
        onPressed: () async {
          await Provider.of<AuthenticatorProvider>(context, listen: false)
              .removeAccount(account.id);
          Navigator.of(context).pop();
        },
        child: TextScale(child: Text(
          AppLocalizations.of(context).deleteAccountDialogDeleteButton,
          style: const TextStyle(fontSize: 18),
        ))
    );
  }

}