/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:convert';

import 'package:flutter/material.dart';

/// Returns the initials of a name.
///
/// ```dart
/// getInitials('John Doe', 2) == 'JD'
/// ```
String getInitials(String str, {int limitTo}) {
  if (str.isEmpty) {
    return str;
  }

  str = str.toUpperCase();

  final StringBuffer buffer = StringBuffer();
  final List<String> wordList = str.trim().split(' ');

  // Take first character if string is a single word
  if (wordList.length <= 1) {
    return str.characters.first;
  }

  // Fallback to actual word count if expected word count is greater
  if (limitTo != null && limitTo > wordList.length) {
  for (int i = 0; i < wordList.length; i++) {
    buffer.write(wordList[i][0]);
  }
    return buffer.toString();
  }

  // Handle all other cases
  for (int i = 0; i < (limitTo ?? wordList.length); i++) {
    buffer.write(wordList[i][0]);
  }

  return buffer.toString();
}

/// Returns a hexadecimal color for a string.
///
/// ```dart
/// stringToColour('John Doe') == '#a55c80'
/// ```
String stringToColour(String str) {
  int hash = 0;
  for (int i = 0; i < str.length; i++) {
    hash = str.codeUnitAt(i) + ((hash << 5) - hash);
  }

  String colour = '#';
  for (int i = 0; i < 3; i++) {
    final int value = (hash >> (i * 8)) & 0xFF;
    final String radix = '00${value.toRadixString(16)}';
    colour += radix.substring(radix.length-2);
  }

  return colour;
}

/// Returns copyright date
String copyrightForgerock() {
  final DateTime now = DateTime.now();
  final String copyrightDate ='Copyright © 2016-${now.year.toString()} | ForgeRock AS';
  return copyrightDate;
}

/// Returns a string representation for a timestamp.
String timestampToDate(int timestamp) {
  final DateTime now = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final String convertedDateTime =
      "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  return convertedDateTime;
}

/// Separate Date and Time from String
List<String> timestampToDateArray(int timestamp) {
  return timestampToDate(timestamp).split(' ');
}

/// Encode string to Base64 format
String base64Encode(String str) {
  final List<int> bytes = utf8.encode(str);
  final String base64Str = base64.encode(bytes);
  return base64Str;
}

/// Returns if a string is a valid email
bool isValidEmail(String email) {
  return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(email);
}

/// Returns color from HEX string
Color colorFromHex(String hexColor) {
  final String hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}

