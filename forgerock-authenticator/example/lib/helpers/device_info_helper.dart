/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

// ignore_for_file: avoid_classes_with_only_static_members

import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoHelper {

  static Future<String> getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version}, build ${packageInfo.buildNumber}';
  }

}