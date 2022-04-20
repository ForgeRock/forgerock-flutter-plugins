/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

// ignore_for_file: unnecessary_string_escapes

import 'package:base32/base32.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator/models/mechanism.dart';
import 'package:forgerock_authenticator_example/helpers/diagnostic_logger.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';
import 'package:provider/provider.dart';

import '../../widgets/alert.dart';
import 'account_add_options.dart';

class AccountAdd extends StatefulWidget {

  const AccountAdd({Key key}) : super(key: key);

  @override
  State<AccountAdd> createState() => AccountAddState();
}

class AccountAddState extends State<AccountAdd> {
  final TextEditingController _issuer = TextEditingController();
  final TextEditingController _accountName = TextEditingController();
  final TextEditingController _sharedSecret = TextEditingController();
  final TextEditingController _counter = TextEditingController(text: '0');
  final TextEditingController _period = TextEditingController(text: '60');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> _oathTypeValues = <String>['HOTP', 'TOTP'];
  final List<String> _algorithmValues = <String>['SHA1', 'SHA256', 'SHA512'];
  final List<String> _digitsValues = <String>['6', '8'];

  final RegExp invalidChars = RegExp('[\~|\`|\^|\<|\>|\&|\?|\{|\}]');

  String _oathType = 'TOTP';
  String _algorithm = 'SHA1';
  String _digits = '6';

  @override
  void dispose() {
    _issuer.dispose();
    _accountName.dispose();
    _sharedSecret.dispose();
    _counter.dispose();
    _period.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        boxShadow: <BoxShadow>[
            BoxShadow(blurRadius: 0.2, color: Colors.grey[300], spreadRadius: 0.1)
          ]
      ),
      child: Form(
        key: _formKey,
        child:
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            horizontalDivider(),
            title(),
            horizontalDivider(),
            issuerField(),
            horizontalDivider(),
            accountNameField(),
            horizontalDivider(),
            sharedSecretField(),
            horizontalDivider(),
            Row(children: <Widget>[
              oathTypeField(),
              verticalDivider(),
              algorithmField(),
            ]),
            horizontalDivider(),
            Row(children: <Widget>[
              digitsField(),
              verticalDivider(),
              periodOrCounterField(),
            ]),
            horizontalDivider(height: 20),
            registerButton(),
          ],
        )
      )
    );
  }

  Widget horizontalDivider({double height}) {
    if(height != null) {
      return SizedBox(height: height);
    } else {
      return const SizedBox(height: 14);
    }
  }

  Widget verticalDivider() {
    return const SizedBox(width: 12);
  }

  Widget title() {
    return Center(
      child: TextScale(child: Text(AppLocalizations.of(context).addAccountFormTitle,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black
        )
      ))
    );
  }

  Widget issuerField() {
    return TextScale(child: TextFormField(
      controller: _issuer,
      decoration: InputDecoration(
        icon: const Icon(Icons.location_city),
        border: const OutlineInputBorder(),
        labelStyle: const TextStyle(fontSize: 20),
        labelText: AppLocalizations.of(context).addAccountFormIssuer,
      ),
      validator: (String value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).formValidationEmptyField;
        } else if (value.trim().isEmpty) {
          return AppLocalizations.of(context).formValidationJustSpaces;
        } else if(invalidChars.hasMatch(value)) {
          return AppLocalizations.of(context).formValidationInvalidChar;
        }
        return null;
      },
    ));
  }

  Widget accountNameField() {
    return TextScale(child: TextFormField(
      controller: _accountName,
      decoration: InputDecoration(
        icon: const Icon(Icons.person),
        border: const OutlineInputBorder(),
        labelStyle: const TextStyle(fontSize: 20),
        labelText: AppLocalizations.of(context).addAccountFormAccountName,
      ),
      validator: (String value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).formValidationEmptyField;
        } else if (value.trim().isEmpty) {
          return AppLocalizations.of(context).formValidationJustSpaces;
        } else if(invalidChars.hasMatch(value)) {
          return AppLocalizations.of(context).formValidationInvalidChar;
        }
        return null;
      },
    ));
  }

  Widget sharedSecretField() {
    return TextScale(child: TextFormField(
      controller: _sharedSecret,
      decoration: InputDecoration(
        icon: const Icon(Icons.vpn_key),
        border: const OutlineInputBorder(),
        labelStyle: const TextStyle(fontSize: 20),
        labelText: AppLocalizations.of(context).addAccountFormSharedSecret,
      ),
      validator: (String value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).formValidationEmptyField;
        } else if(_validateBase32(value) == null) {
          return AppLocalizations.of(context).formValidationInvalidSecret;
        }
        return null;
      },
    ));
  }

  Widget oathTypeField() {
    return Expanded(
        flex: 1,
        child: TextScale(child: DropdownButtonFormField<String>(
          value: 'TOTP',
          decoration: InputDecoration(
            icon: const Icon(Icons.lock),
            border: const OutlineInputBorder(),
            labelStyle: const TextStyle(fontSize: 20),
            labelText: AppLocalizations.of(context).addAccountFormOathType,
          ),
          isExpanded: true,
          onChanged: (String value) {
            setState(() {
              _oathType = value;
            });
          },
          items: _oathTypeValues.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: TextScale(child: Text(
                value,
              )),
            );
          }).toList(),
        ))
    );
  }

  Widget algorithmField() {
    return Expanded(
        flex: 1,
        child: TextScale(child: DropdownButtonFormField<String>(
          value: 'SHA1',
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelStyle: const TextStyle(fontSize: 20),
            labelText: AppLocalizations.of(context).addAccountFormAlgorithm,
          ),
          isExpanded: true,
          onChanged: (String value) {
            setState(() {
              _algorithm = value;
            });
          },
          items: _algorithmValues.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: TextScale(child: Text(
                value,
              )),
            );
          }).toList(),
        ))
    );
  }

  Widget digitsField() {
    return Expanded(
        flex: 1,
        child: TextScale(child: DropdownButtonFormField<String>(
          value: '6',
          decoration: InputDecoration(
            icon: const Icon(Icons.lock_clock),
            border: const OutlineInputBorder(),
            labelStyle: const TextStyle(fontSize: 20),
            labelText: AppLocalizations.of(context).addAccountFormDigits,
          ),
          isExpanded: true,
          onChanged: (String value) {
            setState(() {
              _digits = value;
            });
          },
          items: _digitsValues.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
              ),
            );
          }).toList(),
        ))
    );
  }

  Widget periodOrCounterField() {
    if(_oathType == 'TOTP') {
      return Expanded(
          flex: 1,
          child: TextScale(child: TextFormField(
            controller: _period,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(fontSize: 20),
              labelText: AppLocalizations.of(context).addAccountFormPeriod,
            ),
            validator: (String value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context).formValidationEmptyField;
              } else if (value.trim().isEmpty) {
                return AppLocalizations.of(context).formValidationJustSpaces;
              } else if (int.tryParse(value) == null){
                return AppLocalizations.of(context).formValidationInvalidType;
              } else if (int.tryParse(value) < 1 || int.tryParse(value) > 99) {
                return AppLocalizations.of(context).formValidationInvalidPeriod;
              }
              return null;
            },
          ))
      );
    } else {
      return Expanded(
          flex: 1,
          child: TextScale(child: TextFormField(
            controller: _counter,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(fontSize: 20),
              labelText: AppLocalizations.of(context).addAccountFormCounter,
            ),
            validator: (String value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context).formValidationEmptyField;
              } else if (value.trim().isEmpty) {
                return AppLocalizations.of(context).formValidationJustSpaces;
              } else if (int.tryParse(value) == null){
                return AppLocalizations.of(context).formValidationInvalidType;
              } else if (int.tryParse(value) < 0){
                return AppLocalizations.of(context).formValidationCounterNegative;
              }
              return null;
            },
          ))
      );
    }
  }

  Widget registerButton() {
    return ElevatedButton(
      key: const Key('register-button'),
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
          final BuildContext rootContext = context.findRootAncestorStateOfType<NavigatorState>().context;
          final String uri = _parseFieldsToURI();
          Provider.of<AuthenticatorProvider>(context, listen: false)
              .addAccount(uri)
              .then((Mechanism value) {
                if(value != null) {
                  Navigator.of(context).pop();
                  showAddAccountResult(rootContext, true);
                }
              })
              .catchError((Object error) {
                DiagnosticLogger.severe('Error creating manual account', error);
                Navigator.of(context).pop();
                alert(rootContext, AppLocalizations.of(rootContext).errorTitle, error.toString());
              });
        }
      },
      child: TextScale(child: Text(
        AppLocalizations.of(context).addAccountFormRegisterButton,
        style: const TextStyle(fontSize: 16),
      ))
    );
  }

  String _validateBase32(String value) {
    try {
      final String base32String = base32.decodeAsHexString(value);
      return base32String;
    } catch (e) {
      DiagnosticLogger.severe('Error validating base32', e);
      return null;
    }
  }

  String _parseFieldsToURI() {
    String uri = 'otpauth://${_oathType.toLowerCase()}/${_issuer.text}:${_accountName.text}?secret=${_sharedSecret.text}&digits=$_digits&algorithm=$_algorithm';
    if(_oathType == 'TOTP') {
      uri += '&period=${_period.text}';
    } else {
      uri += '&counter=${_counter.text}';
    }
    return Uri.encodeFull(uri);
  }

}
