/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator/models/oath_mechanism.dart';
import 'package:forgerock_authenticator/models/oath_token_code.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';
import 'package:forgerock_authenticator_example/providers/settings_provider.dart';
import 'package:forgerock_authenticator_example/util/token_util.dart';
import 'package:provider/provider.dart';

import '../../widgets/count_down_timer.dart';

class OtpDetail extends StatefulWidget {
  const OtpDetail({Key key, this.account}) : super(key: key);

  final Account account;

  @override
  State<OtpDetail> createState() => OtpDetailState();
}

class OtpDetailState extends State<OtpDetail> {

  Future<OathTokenCode> _oathTokenCode;
  CountDownController _controller;
  TokenType _tokenType;
  int _duration;

  Account get account => widget.account;

  @override
  void initState() {
    super.initState();
    _oathTokenCode = getNextOathTokenCode();
    _controller = CountDownController();
    _duration = 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OathTokenCode>(
        future: _oathTokenCode,
        builder: (BuildContext context, AsyncSnapshot<OathTokenCode> snapshot) {
          if(snapshot.hasData) {
            setTokenType(snapshot.data.oathType);
            if(_duration == 0) {
              setDuration(getDuration(snapshot.data));
            }
            return OtpRow(
              countDownController: _controller,
              oathTokenCode: snapshot.data,
              onRefresh: refresh,
            );
          } else {
            return Container();
          }
        });
  }

  void setTokenType(TokenType tokenType) {
    _tokenType = tokenType;
  }

  void setDuration(int duration) {
    _duration = duration;
  }

  void refresh() {
    if(account.hasOathMechanism() && _tokenType == TokenType.TOTP) {
      _controller.restart(duration: _duration);
    }

    setState(() {
      _oathTokenCode = getNextOathTokenCode();
    });
  }

  Future<OathTokenCode> getNextOathTokenCode() async {
    return Provider.of<AuthenticatorProvider>(context, listen: false).getOathTokenCode(account.getOathMechanism().id);
  }
}

class OtpRow extends StatelessWidget {

  const OtpRow({Key key, this.oathTokenCode, this.countDownController, this.onRefresh}) : super(key: key);

  final OathTokenCode oathTokenCode;
  final CountDownController countDownController;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if(Provider.of<SettingsProvider>(context, listen: false).copyCode) Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(0, 12, 10, 0),
                child: SizedBox(
                    height: 28.0,
                    width: 28.0,
                    child: IconButton(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      color: Colors.grey[400],
                      icon: const Icon(Icons.copy, size: 28.0, key: Key('copyAction')),
                      onPressed: () {
                        copyCode(context, oathTokenCode.code);
                      },
                    )
                ),
              )
            ],
          ),
          Column(
            children: <Widget>[
              InkWell(
                  onTap: () {
                    copyCode(context, oathTokenCode.code);
                  },
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                      child:Text(
                        formatCode(oathTokenCode),
                        style: const TextStyle(fontSize: 38, color: Colors.black, fontWeight: FontWeight.w600),
                        key: const Key('otpCode'),
                        textScaleFactor: 1.0,
                      )
                  )
              )
            ],
          ),
          Column(
            children: <Widget>[
              OtpAction(
                oathTokenCode: oathTokenCode,
                countDownController: countDownController,
                onRefresh: onRefresh,
              )
            ],
          ),
        ], key: const Key('accountDetailVisible')
    );
  }

  void copyCode(BuildContext context, String code) {
    SnackBar snackBar;
    if(Provider.of<SettingsProvider>(context, listen: false).copyCode) {
      snackBar = SnackBar(
        content: Text(AppLocalizations.of(context).accountListCodeCopied,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.height > 800 ? 18 : 16,
              height: 1.3, color: Colors.white,
              fontWeight: FontWeight.w500
          ),
        ),
        backgroundColor: const Color(0xFF34A853),
      );
      Clipboard.setData(ClipboardData(text: code));
    } else {
      snackBar = SnackBar(
        content: Text(AppLocalizations.of(context).accountListCodeNotCopied),
        backgroundColor: const Color(0xFF34A853),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}

class OtpAction extends StatelessWidget {

  const OtpAction({Key key, this.oathTokenCode, this.countDownController, this.onRefresh}) : super(key: key);

  final OathTokenCode oathTokenCode;
  final CountDownController countDownController;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if(oathTokenCode.oathType == TokenType.TOTP) {
      return Container(
        padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
        child: RepaintBoundary(child: CircularCountdown(
          timeRemaining: getSecondsLeft(oathTokenCode),
          timeTotal: getDuration(oathTokenCode),
          countDownController: countDownController,
          onRefresh: onRefresh,
        )),
      );
    } else {
      return Container(
          padding: const EdgeInsets.fromLTRB(6, 0, 23, 0),
          child:SizedBox(
              height: 32.0,
              width: 32.0,
              child: IconButton(
                color: Colors.grey[400],
                icon: const Icon(Icons.change_circle_outlined, size: 38.0, key: Key('refreshAction')),
                onPressed: onRefresh,
              )
          )
      );
    }
  }

}

class CircularCountdown extends StatelessWidget {
  const CircularCountdown(
      {Key key,
      this.timeRemaining,
      this.timeTotal,
      this.countDownController,
      this.onRefresh})
      : super(key: key);

  final int timeRemaining;
  final int timeTotal;
  final CountDownController countDownController;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return AnimatedCountDownTimer(
      timeTotal: timeTotal,
      timeRemaining: timeRemaining,
      countDownController: countDownController,
      width: 48,
      height: 48,
      onComplete: onRefresh,
    );
    // return CountDownTimer(
    //   timeTotal: timeTotal,
    //   timeRemaining: timeRemaining,
    //   width: 38,
    //   height: 38,
    //   onComplete: onRefresh
    // );
  }

}