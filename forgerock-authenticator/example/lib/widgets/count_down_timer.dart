/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:async';

import 'package:flutter/material.dart';

/// This widget creates a circular container with a countdown with duration in
/// seconds.
class CountDownTimer extends StatefulWidget {

  const CountDownTimer({
    Key key,
    this.timeRemaining,
    this.onComplete,
    this.width,
    this.height,
    this.timeTotal}) : super(key: key);

  final int timeTotal;
  final int timeRemaining;
  final VoidCallback onComplete;
  final double width;
  final double height;

  @override
  State<CountDownTimer> createState() => CountDownTimerState();
}

class CountDownTimerState extends State<CountDownTimer> {
  Timer _timer;
  int _start;

  @override
  void initState() {
    _start = widget.timeRemaining;
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(width: 4, color: Colors.grey[400])
      ),
      child: Center(child: Text(
        '$_start',
        textScaleFactor: 1.0,
        style: TextStyle(
            fontSize: 15.0,
            color: _start > (widget.timeRemaining / 3)
                ? Colors.grey
                : Colors.red,
            fontWeight: FontWeight.bold),
      ),
    ));
  }

  void _onComplete() {
    if (widget.onComplete != null) {
      widget.onComplete();
    }
    setState(() {
      _start = widget.timeTotal;
      _startTimer();
    });
  }

  void _startTimer() {
    const Duration oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _onComplete();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

}
