/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

/// The supported Push types.
enum PushType { DEFAULT, CHALLENGE, BIOMETRIC }

/// Helper extension for PushType.
extension PushTypeExtension on PushType {
  /// Return value of PushType.
  String get value {
    switch (this) {
      case PushType.DEFAULT:
        return "default";
      case PushType.CHALLENGE:
        return "challenge";
      case PushType.BIOMETRIC:
        return "biometric";
      default:
        return "";
    }
  }

  /// Compare PushType with given value.
  bool isEqual(dynamic typeValue) {
    if (typeValue is String) {
      return this.toString() == typeValue || this.value == typeValue;
    } else if (typeValue is PushType) {
      return this.value == typeValue.value;
    } else {
      return false;
    }
  }
}

/// Return PushType for given String value.
/// If value does not match, returns DEFAULT.
extension PushTypeParsing on String {
  PushType parsePushType() {
    switch (this) {
      case "default":
        return PushType.DEFAULT;
      case "challenge":
        return PushType.CHALLENGE;
      case "biometric":
        return PushType.BIOMETRIC;
      default:
        return PushType.DEFAULT;
    }
  }
}
