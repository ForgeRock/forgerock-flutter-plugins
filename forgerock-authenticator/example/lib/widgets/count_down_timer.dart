/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CountDownTimer extends StatefulWidget {

  const CountDownTimer({Key key, this.timeRemaining, this.onComplete, this.width, this.height, this.timeTotal}) : super(key: key);

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
            color: _start > (widget.timeRemaining / 3) ? Colors.grey : Colors.red,
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

class AnimatedCountDownTimer extends StatefulWidget {

  const AnimatedCountDownTimer({
    Key key,
    this.timeTotal,
    this.timeRemaining,
    this.onComplete,
    this.onStart,
    this.countDownController,
    this.width,
    this.height})
      : super(key: key);

  final int timeTotal;
  final int timeRemaining;
  final VoidCallback onComplete;
  final VoidCallback onStart;
  final CountDownController countDownController;
  final double width;
  final double height;

  @override
  AnimatedCountDownTimerState createState() => AnimatedCountDownTimerState();
}

class AnimatedCountDownTimerState extends State<AnimatedCountDownTimer>
    with TickerProviderStateMixin {

  AnimationController _controller;
  Animation<double> _countDownAnimation;

  String get timeRemainingString {
    final Duration duration = _controller.duration * _controller.value;
    return (duration.inSeconds).toString().padLeft(2, '0');
  }

  String get timeTotalString {
    return '${widget.timeTotal}';
  }

  int _getDuration() {
    if (widget.timeRemaining != null)
      return widget.timeRemaining;
    else
      return 30;
  }

  void _onStart() {
    if (widget.onStart != null) {
      widget.onStart();
    }
  }

  void _onComplete() {
    if (widget.onComplete != null) {
      widget.onComplete();
    }
  }

  void _setController() {
    widget.countDownController?._state = this;
    _controller?.value = 1;

    widget.countDownController?.start();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _getDuration()),
    );

    _controller.addStatusListener((AnimationStatus status) {
      switch (status) {
        case AnimationStatus.forward:
          _onStart();
          break;
        case AnimationStatus.reverse:
          _onStart();
          break;
        case AnimationStatus.dismissed:
          _onComplete();
          break;
        default:
        // Do nothing
      }
    });

    // Reverse animation
    // _countDownAnimation = Tween<double>(begin: 1, end: 0).animate(_controller);
    _setController();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
          animation: _controller,
          child: CounterWidget(
            countDownController: widget.countDownController,
            controller: _controller,
            countDownAnimation: _countDownAnimation,
          ),
          builder: (BuildContext context, Widget child) {
            return Stack(
              children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: child
              )
            ]);
          }),
    );
  }

}

class CounterWidget extends StatelessWidget {

  const CounterWidget({Key key, this.controller, this.countDownAnimation, this.countDownController}) : super(key: key);

  final AnimationController controller;
  final Animation<double> countDownAnimation;
  final CountDownController countDownController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CustomPaint(
          painter: CustomTimerPainter(
            countDownController: countDownController,
            animation: countDownAnimation ?? controller,
            backgroundColor: Colors.grey[300],
            color: Colors.grey,
          )
        ),
      ),
    );
  }
  
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    this.countDownController,
    this.animation,
    this.backgroundColor,
    this.color,
    this.strokeWidth = 4.0,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final CountDownController countDownController;
  final Color backgroundColor, color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);

    paint.color = color;
    const double startAngle = math.pi * 1.5;
    final double sweepAngle = animation.value * 2 * math.pi;

    if (animation.value > 0.33) {
      paint.color = color;
    } else {
      paint.color = Colors.red[400];
    }

    // Draws the circle
    canvas.drawArc(Offset.zero & size, startAngle, sweepAngle, false, paint);

    // Draws the current time remaining in the middle of the widget
    const TextStyle textStyle = TextStyle(
      color: Colors.grey,
      fontSize: 15,
      fontWeight: FontWeight.bold
    );
    if (textStyle != null) {
      final double _innerDiameter = _getInnerDiameter(size.width);
      final TextSpan text = TextSpan(
        text: countDownController.getTime(),
        style: textStyle,
      );
      final TextPainter textPainter = TextPainter(
        text: text,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(
        minWidth: _innerDiameter,
        maxWidth: _innerDiameter,
      );
      final BoxConstraints constraints = BoxConstraints(
        maxWidth: _innerDiameter,
        maxHeight: _innerDiameter,
      );
      final RenderParagraph renderParagraph = RenderParagraph(
        text,
        textDirection: TextDirection.ltr,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: TextAlign.center,
      )..layout(constraints);
      final double textWidth =
      renderParagraph.getMinIntrinsicWidth(size.width / 2).ceilToDouble();
      final double textHeight =
      renderParagraph.getMinIntrinsicHeight(size.width / 2).ceilToDouble();
      final Offset offset = Offset(
        size.width / 2 - textWidth / 2,
        size.height / 2 - textHeight / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(CustomTimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }

  double _getInnerDiameter(double width) =>
      math.max(0, width - 2 * strokeWidth);
}

class CountDownController {
  AnimatedCountDownTimerState _state;

  void start() {
      _state._controller?.reverse(from: 1);
  }

  void pause() {
    _state._controller?.stop(canceled: false);
  }

  void resume() {
    _state._controller?.reverse(from: _state._controller.value);
  }

  void restart({int duration}) {
    _state._controller.duration =
        Duration(seconds: duration ?? _state._controller.duration.inSeconds);
    _state._controller.reverse(from: 1);
  }

  String getTime() {
    return _state.timeRemainingString;
  }
}