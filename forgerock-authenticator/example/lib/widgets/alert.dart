/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';

/// displays an modal with the supplied title and message
Future<void> alert(BuildContext context, String title, String message) =>
    showDialog(
        context: context,
        builder: (BuildContext innerContext) => AlertDialog(
          title: TextScale(child: Text(
            title,
            style: const TextStyle(color: Colors.black),
          )),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextScale(child: Text(
                  message,
                  style: const TextStyle(color: Colors.black),
                )),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: TextScale(child: Text(AppLocalizations.of(context).alertDialogOkButton)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ));