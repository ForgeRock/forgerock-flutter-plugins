/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator_example/widgets/page_switcher.dart';

import 'account_detail.dart';

class AccountDetailSwitcher extends StatefulWidget {

  const AccountDetailSwitcher({Key key, this.account}) : super(key: key);

  final Account account;

  @override
  State<AccountDetailSwitcher> createState() => AccountDetailSwitcherState();
}

class AccountDetailSwitcherState extends State<AccountDetailSwitcher> {
  PageController _controller;
  int _currentIndex = 0;

  Account get account => widget.account;

  @override
  void initState() {
    super.initState();

    if(account.hasMultipleMechanisms()) {
      _controller = PageController();
    }
  }

  @override
  Widget build(BuildContext context) {
    if(account.hasMultipleMechanisms()) {
      final List<AccountDetail> data = <AccountDetail>[
        AccountDetail(account: account, isOTP: true),
        AccountDetail(account: account, isOTP: false),
      ];
      return SizedBox(
          key: const Key('multiple-mechanisms'),
          height: 70,
          child: Column(
            children: <Widget>[
              Flexible(
                  child:
                  Container(
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
                      )
                  ),
                  flex: 3
              ),
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(data.length,
                          (int index) => PageSwitcher(
                              index: index,
                              currentIndex: _currentIndex
                          )
                  ),
                ),
              )
            ],
          ));
    } else {
      return SizedBox(
          key: const Key('single-mechanism'),
          height: 70,
          child: AccountDetail(account: account, isOTP: account.hasOathMechanism())
      );
    }
  }

}

