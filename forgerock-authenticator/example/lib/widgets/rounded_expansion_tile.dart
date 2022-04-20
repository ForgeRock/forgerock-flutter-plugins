/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RoundedExpansionTile extends StatefulWidget {

  const RoundedExpansionTile({
    Key key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.duration,
    this.children,
    this.autofocus,
    this.contentPadding,
    this.dense,
    this.enabled,
    this.enableFeedback,
    this.focusColor,
    this.focusNode,
    this.horizontalTitleGap,
    this.hoverColor,
    this.isThreeLine,
    this.minLeadingWidth,
    this.minVerticalPadding,
    this.mouseCursor,
    this.onLongPress,
    this.selected,
    this.selectedTileColor,
    this.shape,
    this.tileColor,
    this.visualDensity,
    this.curve,
    this.childrenPadding,
    this.rotateTrailing,
    this.noTrailing,
    this.expanded
  }) : super(key: key);

  final bool autofocus;
  final EdgeInsetsGeometry contentPadding;
  final bool dense;
  final bool enabled;
  final bool enableFeedback;
  final Color focusColor;
  final FocusNode focusNode;
  final double horizontalTitleGap;
  final Color hoverColor;
  final bool isThreeLine;
  final Widget leading;
  final double minLeadingWidth;
  final double minVerticalPadding;
  final MouseCursor mouseCursor;
  final void Function() onLongPress;
  final bool selected;
  final Color selectedTileColor;
  final ShapeBorder shape;
  final Widget subtitle;
  final Widget title;
  final Color tileColor;
  final Widget trailing;
  final VisualDensity visualDensity;
  final Duration duration;
  final List<Widget> children;
  final Curve curve;
  final EdgeInsets childrenPadding;
  final bool rotateTrailing;
  final bool noTrailing;
  final bool expanded;

  @override
  RoundedExpansionTileState createState() => RoundedExpansionTileState();
}

class RoundedExpansionTileState extends State<RoundedExpansionTile>
    with TickerProviderStateMixin {
  bool _expanded;
  bool _rotateTrailing;
  bool _noTrailing;
  AnimationController _controller;
  AnimationController _iconController;

  // When the duration of the ListTile animation is NOT provided. This value will be used instead.
  Duration defaultDuration = const Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _expanded = widget.expanded ?? false;
    // If not provided, this will be true
    _rotateTrailing =
    widget.rotateTrailing ?? true;
    // If not provided this will be false
    _noTrailing = widget.noTrailing ?? false;
    _controller = AnimationController(
        vsync: this,
        duration: widget.duration ?? defaultDuration);

    _iconController = AnimationController(
      duration: widget.duration ?? defaultDuration,
      vsync: this,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            // If bool is not provided the default will be false.
            autofocus: widget.autofocus ?? false,
            contentPadding: widget.contentPadding,
            // If bool is not provided the default will be false.
            dense: widget.dense ?? false,
            // If bool is not provided the default will be true.
            enabled: widget.enabled ?? true,
            enableFeedback:
            // If bool is not provided the default will be false.
            widget.enableFeedback ?? false,
            focusColor: widget.focusColor,
            focusNode: widget.focusNode,
            horizontalTitleGap: widget.horizontalTitleGap,
            hoverColor: widget.hoverColor,
            // If bool is not provided the default will be false.
            isThreeLine:
            widget.isThreeLine ?? false,
            key: widget.key,
            leading: widget.leading,
            minLeadingWidth: widget.minLeadingWidth,
            minVerticalPadding: widget.minVerticalPadding,
            mouseCursor: widget.mouseCursor,
            onLongPress: widget.onLongPress,
            // If bool is not provided the default will be false.
            selected: widget.selected ?? false,
            selectedTileColor: widget.selectedTileColor,
            shape: widget.shape,
            subtitle: widget.subtitle,
            title: widget.title,
            tileColor: widget.tileColor,
            trailing: _noTrailing ? null : _trailingIcon(),
            visualDensity: widget.visualDensity,
            onTap: () {
              setState(() {
                // Checks if the ListTile is expanded and sets state accordingly.
                if (_expanded) {
                  _expanded = !_expanded;
                  _controller.forward();
                  _iconController.reverse();
                } else {
                  _expanded = !_expanded;
                  _controller.reverse();
                  _iconController.forward();
                }
              });
            },
          ),
          AnimatedCrossFade(
            firstCurve: widget.curve ?? Curves.fastLinearToSlowEaseIn,
            secondCurve: widget.curve ?? Curves.fastLinearToSlowEaseIn,
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration:
            widget.duration ?? defaultDuration,
            firstChild: SizedBox(
                height: 70,
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: widget.childrenPadding,
                  shrinkWrap: true,
                  children: widget.children,
                )),
            secondChild: Container()),
        ]);
  }

  // Build trailing widget based on the user input.
  Widget _trailingIcon() {
    if (widget.trailing != null) {
      if (_rotateTrailing) {
        return RotationTransition(
            turns: Tween<double>(begin: 0.0, end: 0.5).animate(_iconController),
            child: widget.trailing);
      } else {
        return widget.trailing;
      }
    } else {
      return AnimatedIcon(
          icon: AnimatedIcons.close_menu, progress: _controller);
    }
  }
}
