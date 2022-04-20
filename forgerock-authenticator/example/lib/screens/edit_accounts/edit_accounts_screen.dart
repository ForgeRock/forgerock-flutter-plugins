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
import 'package:forgerock_authenticator_example/screens/edit_accounts/account_card_edit.dart';
import 'package:forgerock_authenticator_example/widgets/app_bar.dart';
import 'package:forgerock_authenticator_example/widgets/empty_list.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';
import 'package:provider/provider.dart';

class EditAccountsScreen extends StatefulWidget {

  const EditAccountsScreen({Key key}) : super(key: key);

  @override
  EditAccountsScreenState createState() => EditAccountsScreenState();
}

class EditAccountsScreenState extends State<EditAccountsScreen> {

  List<String> accountList = <String>[];

  @override
  void initState() {
    super.initState();
    _getAccountOrderIndex().then((List<String> value) => accountList = value);

    Provider
        .of<AuthenticatorProvider>(context, listen: false)
        .getIndexNotifier()
        .addListener(() {
          _updateAccountList();
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(accountList.isEmpty) {
      accountList = Provider
          .of<AuthenticatorProvider>(context, listen: false)
          .getAccountOrderIndex();
    }
    return Scaffold(
      appBar: ForgeRockAppBar(
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child:
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: TextScale(child: Text(
                    AppLocalizations.of(context).editAccountsDone,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height > 800 ? 18 : 16,
                        height: 1.3, color: Colors.black,
                        fontWeight: FontWeight.w500),
                  )),
                )
            ),
          ],
      ),
      body: _accountListBody()
    );
  }

  Widget _accountListBody() {
    if(accountList.isNotEmpty) {
      return ReorderableListView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          children: _getAccountList(),
          onReorder: _reorderData
      );
    } else {
      return EmptyList(
        image: 'assets/images/fr-icon-no-accounts.png',
        header: AppLocalizations.of(context).noAccountListHeader,
        description: AppLocalizations.of(context).noAccountListDescription,
      );
    }
  }

  List<Widget> _getAccountList() {
    return List<AccountCardEdit>.generate(accountList.length, (int index) {
      return AccountCardEdit(
          key: ValueKey<String>(accountList[index]),
          account: _getAccount(accountList[index])
      );
    });
  }

  Future<void> _updateAccountList() async {
    if (mounted) {
      final List<String> value = await _getAccountOrderIndex();
      setState(() {
        accountList = value;
      });
    }
  }

  Future<List<String>> _getAccountOrderIndex() async {
    return Provider
        .of<AuthenticatorProvider>(context, listen: false)
        .getAccountOrderIndex();
  }

  Account _getAccount(String accountId) {
    return Provider
        .of<AuthenticatorProvider>(context, listen: false)
        .getAccount(accountId);
  }

  void _saveOrder() {
    if(accountList.isNotEmpty) {
      Provider
          .of<AuthenticatorProvider>(context, listen: false)
          .setAccountOrderIndex(accountList);
    }
  }

  void _reorderData(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String newAccount = accountList.removeAt(oldIndex);
      accountList.insert(newIndex, newAccount);
      _saveOrder();
    });
  }

}