/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/material.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';

class PageData {
  PageData({this.title, this.description, this.image, this.backgroundColor});

  final String title;
  final String description;
  final String image;
  final Color backgroundColor;
}

class IntroPage extends StatelessWidget {

  const IntroPage({Key key, this.data}): super(key: key);

  final PageData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment : MainAxisAlignment.center,
      crossAxisAlignment : CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 12),
          child: Image.asset(
              data.image,
              height: MediaQuery.of(context).size.height > 800
                  ? MediaQuery.of(context).size.height * 0.33
                  : MediaQuery.of(context).size.height * 0.27,
              alignment: Alignment.center
          )
        ),
        Text(
          data.title,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height > 800 ? 38 : 32,
            fontWeight: FontWeight.w500,
            color: const Color(0XFF006AC8),
            height: 2.0),
          textAlign: TextAlign.center,
          textScaleFactor: 1.0,
          overflow: data.title.length > 12 ? TextOverflow.fade : TextOverflow.visible,
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 0),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextScale(
            maxFactor: 1.2,
            child: Text(
              data.description,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: MediaQuery.of(context).size.height > 800 ? 20.0 : 18,
                  height: 1.3),
              textAlign: TextAlign.center,
              overflow: data.description.length > 160 ? TextOverflow.fade : TextOverflow.visible,
            )
          )
        )
      ],
    );
  }

}
