/*
 * Copyright (c) 2022-2025 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:forgerock_authenticator/models/account.dart';
import 'package:forgerock_authenticator/models/oath_mechanism.dart';
import 'package:forgerock_authenticator/models/oath_token_code.dart';
import 'package:forgerock_authenticator_example/providers/authenticator_provider.dart';

import 'count_down_timer.dart';

/// This widget is used with OATH accounts to display an [OathTokenCode].
class AccountDetail extends StatefulWidget {
  const AccountDetail(this.account, {super.key});

  final Account account;

  @override
  State<AccountDetail> createState() => _AccountDetailState();
}

class _AccountDetailState extends State<AccountDetail> {
  late Future<OathTokenCode?> _oathTokenCode;
  int _duration = 0;

  Account get account => widget.account;

  @override
  void initState() {
    super.initState();
    _oathTokenCode = _getNextOathTokenCode();
  }

  void refresh() {
    setState(() {
      _duration = 0;
      _oathTokenCode = _getNextOathTokenCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OathTokenCode?>(
      future: _oathTokenCode,
      builder: (BuildContext context, AsyncSnapshot<OathTokenCode?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 38,
            height: 38,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final OathTokenCode? token = snapshot.data;
        if (token == null || token.code == null) {
          return const SizedBox.shrink();
        }

        if (_duration == 0) {
          _duration = _getDuration(token);
        }

        return Row(
          children: [
            Column(
              children: [
                Text(
                  _formatCode(token),
                  style: const TextStyle(fontSize: 32, color: Colors.black),
                )
              ],
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: _displayOtpAction(token),
                )
              ],
            )
          ],
        );
      },
    );
  }

  Widget _displayOtpAction(OathTokenCode token) {
    if (token.oathType == TokenType.TOTP) {
      return CountDownTimer(
        timeTotal: _getDuration(token),
        timeRemaining: _getSecondsLeft(token),
        width: 38,
        height: 38,
        onComplete: refresh,
      );
    }
    return SizedBox(
      height: 38.0,
      width: 38.0,
      child: IconButton(
        padding: const EdgeInsets.all(0.0),
        color: Colors.grey,
        icon: const Icon(Icons.refresh, size: 42.0),
        onPressed: refresh,
      ),
    );
  }

  Future<OathTokenCode?> _getNextOathTokenCode() async {
    final OathMechanism? mechanism = account.getOathMechanism();
    final String? mechanismId = mechanism?.id;
    if (mechanismId == null) {
      return null;
    }
    return Provider.of<AuthenticatorProvider>(context, listen: false)
        .getOathTokenCode(mechanismId);
  }

  String _formatCode(OathTokenCode token) {
    final String code = token.code ?? '';
    if (code.length <= 3) {
      return code;
    }
    final int half = code.length ~/ 2;
    return '${code.substring(0, half)} ${code.substring(half)}';
  }

  int _getSecondsLeft(OathTokenCode token) {
    final int? until = token.until;
    final int? start = token.start;
    if (until == null || start == null) {
      return 0;
    }
    final int cur = DateTime.now().millisecondsSinceEpoch;
    final int total = until - start;
    final int state = cur - start;
    final int secondsLeft = ((total - state) ~/ 1000) + 1;

    return secondsLeft >= 0 ? secondsLeft : 1;
  }

  int _getDuration(OathTokenCode token) {
    final int? until = token.until;
    final int? start = token.start;
    if (until == null || start == null) {
      return 0;
    }
    return (until - start) ~/ 1000;
  }
}
