/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';

class EmptyList extends StatelessWidget {
  const EmptyList({Key key, this.image, this.header, this.description}) : super(key: key);

  final String image;
  final String header;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0XFFF6F5F8),
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Image.asset(
              image,
              key: const Key('image-empty'),
              fit: BoxFit.fitWidth,
              width: 220.0,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: <Widget>[
                  Text(
                    header,
                    key: const Key('header-empty'),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height > 800 ? 32 : 26,
                      fontWeight: FontWeight.w500,
                      color: const Color(0XFF006AC8),
                      height: 2.0
                    ),
                    textScaleFactor: 1.0,
                  ),
                  TextScale(maxFactor: 1.4, child: Text(
                    description,
                    key: const Key('description-empty'),
                    style: const TextStyle(
                      color: Colors.grey,
                      letterSpacing: 1.2,
                      fontSize: 16.0,
                      height: 1.3),
                    textAlign: TextAlign.center,
                  ))
                ],
              ),
            ),
          )
        ],
      ));
  }

}