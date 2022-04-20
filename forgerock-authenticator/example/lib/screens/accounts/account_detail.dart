/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator/models/account.dart';

import 'otp_detail.dart';
import 'push_detail.dart';

class AccountDetail extends StatelessWidget {
  const AccountDetail({Key key, this.account, this.isOTP}) : super(key: key);

  final Account account;
  final bool isOTP;

  @override
  Widget build(BuildContext context) {
    if(isOTP) {
      return OtpDetail(account: account);
    } else {
      return PushDetail(account: account);
    }
  }

}
