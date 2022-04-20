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

class AccountEdit extends StatefulWidget {

  const AccountEdit({Key key, this.account}) : super(key: key);

  final Account account;

  @override
  AccountEditState createState() => AccountEditState();
}

class AccountEditState extends State<AccountEdit> {

  String issuer;
  String accountName;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            const SizedBox(height: 10),
            Center(child:
              TextScale(child: Text(
                  AppLocalizations.of(context).editAccountDialogTitle,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black)
              )
              )
            ),
            const SizedBox(height: 24),
            TextScale(child:TextFormField(
              decoration: InputDecoration(
                icon: const Icon(Icons.location_city),
                border: const OutlineInputBorder(),
                labelStyle: const TextStyle(fontSize: 20),
                labelText: AppLocalizations.of(context).editAccountDialogIssuer,
              ),
              initialValue: widget.account.getIssuer(),
              validator: (String value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context).formValidationEmptyField;
                }
                return null;
              },
              onChanged: (String text) {
                issuer = text;
              },
            )),
            const SizedBox(height: 24),
            TextScale(child: TextFormField(
                decoration: InputDecoration(
                icon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
                labelStyle: const TextStyle(fontSize: 20),
                labelText: AppLocalizations.of(context).editAccountDialogAccountName,
              ),
              initialValue: widget.account.getAccountName(),
              validator: (String value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some value';
                }
                return null;
              },
              onChanged: (String text) {
                accountName = text;
              },
            )),
            const SizedBox(height: 24),
            ElevatedButton(
                key: const Key('save-button'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  primary: const Color(0xFF006AC8),
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  minimumSize: const Size.fromHeight(42),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    Provider.of<AuthenticatorProvider>(context, listen: false)
                        .updateAccount(widget.account.id, issuer, accountName);
                    Navigator.of(context).pop();
                  }
                },
                child: TextScale(child: Text(
                  AppLocalizations.of(context).editAccountDialogSaveButton, style: const TextStyle(fontSize: 16),)
                )
            ),
          ],
        )
    );

  }

}