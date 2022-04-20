/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:math';

import 'package:uuid/uuid.dart';

/// Provide random data for tests
class Randomizer {

  static const String _randomChars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static const List<String> _firstNames = [
    'Ana', 'Andy', 'Albert', 'Alexandre', 'Bela', 'Bernard', 'Bethany', 'Camila', 'Caleb', 'Dave', 'David',
    'Elizabeth', 'Ellen', 'Felipe', 'Francis', 'George', 'Giovanni', 'Harry', 'Hillary', 'Isabella',
    'Ivy', 'Justin', 'James', 'Jennifer', 'Keira', 'Katherine', 'Lewis', 'Luis', 'Maria',  'Micheal', 'Naomi',
    'Nichole', 'Oliver', 'Ollie', 'Paul', 'Peter', 'Rachel', 'Rodrigo', 'Ryan', 'Stephanie', 'Stoyan', 'Samuel',
    'Taylor', 'Thomas', 'Ursula', 'Victor', 'Victoria', 'Wallace', 'Yasmin', 'Zachery',
  ];
  static const List<String> _lastNames = [
    'Abbott', 'Alves', 'Adams', 'Bernhard', 'Barros', 'Collins', 'Conn', 'Douglas', 'Ernser', 'Fadel', 'Gibson',
    'Goodwin', 'Haley', 'Herman', 'King', 'Kreiger', 'Larson', 'Lowe', 'Marvin', 'Mills', 'Olson', "O'Conner",
    'Parker', 'Price', 'Raynor', 'Reis', 'Sanches', 'Stark', 'Thompson', 'Petrov', 'Walker', 'White', 'Ziemann',
  ];
  static const List<String> _issuers = [
    'Allianz', 'AT&T', 'American Express', 'Boeing', 'BMW', 'Bristol-Myers Squibb', 'Canadian Tire', 'Costco',
    'Delta Airlines', 'Disney', 'IBM', 'Facebook', 'FedEx', 'ForgeRock', 'Google', 'J.P. Morgan', 'Microsoft',
    'Nestlé', 'Netflix', 'Nintendo',  'SpaceX', 'Singapore Airlines', 'Starbucks', 'Tesla', 'Toyota Motor', 'Walmart',
  ];
  static const List<String> _secrets = [
    'HNEZ2W7D462P3JYDG2HV7PFB', 'JMEZ2W7D462P3JYDG2HV7PFAN======', 'HNEZ2W7D462P3JYDG2HV7PFBM======',
    '34Q7XL23E4JGJU55NGDTJT2GGU======', '37NMDM6A7JWGEU4ABQUKMOGJO4======', '275CPSHU4KDQO6KEEPJN2DG6MM======',
    'O62XQ3ANHGZMDMOIQA7FRJ4O2M======', 'LGMBDCR5HZPPYY4TNJV4YAP5AM======','NZT4FKADFKM54QGYOA4BGMNMQI======',
    '3GQT3I3O6YURA7YQV6PTNOLF5Y======', 'CEJVSRT7UAS3BWEPEDZCIH66IM======', 'DK3EQGCJOUNKQLM6FTPWTE4ECQ======',
    'VLQ5NFRU7KQORBB6SVCFJ3OOGQ======'
  ];
  static const List<String> _decodedSecrets = [
    '3a099d5be3e7b4fda703368f5fbca1', '3b499d5be3e7b4fda703368f5fbca1'
  ];

  final Random _random = Random();

  /// Return a random first name.
  String getRandomFirstName() {
    return _elementAt(_firstNames);
  }

  /// Return a random last name.
  String getRandomLastName() {
    return _elementAt(_lastNames);
  }

  /// Return a random name (first and last names).
  String getRandomName() {
    return '${getRandomFirstName()} ${getRandomLastName()}';
  }

  /// Generates a user name.
  String getRandomUserName() {
    return ([_elementAt(_firstNames), _elementAt(_lastNames)]..shuffle())
        .join(_elementAt(['_', '.', '-']))
        .toLowerCase();
  }

  /// Generates an email for given issuer.
  String getEmail(String issuer) {
    return [getRandomUserName(), getDomain(issuer)].join('@').toLowerCase();
  }

  /// Generates a domain for a given issuer.
  String getDomain(String issuer) {
    final String domainName = issuer.replaceAll(RegExp(r'(?:\s|[^\w\s])+'),'');
    return '${domainName.toLowerCase()}.com';
  }

  /// Return a random Account name for issuer (email, name, userid).
  String getRandomAccountName(String issuer) {
    switch (_random.nextInt(3)) {
      case 0:
        return getRandomUserName();
      case 1:
        return getRandomName();
      case 2:
        return getEmail(issuer);
      default:
        return getRandomName();
    }
  }

  /// Return a random issuer.
  String getRandomIssuer() {
    return _elementAt(_issuers);
  }

  /// Return a random secret.
  String getRandomSecret() {
    return _elementAt(_secrets);
  }

  /// Return a random decoded secret.
  String getRandomDecodedSecret() {
    return _elementAt(_decodedSecrets);
  }

  /// Get a random element from the given list.
  T _elementAt<T>(List<T> list) {
    return list[_random.nextInt(list.length)];
  }

  /// Return random number of digits for OTP accounts. 6 or 8.
  int getRandomOtpDigits() {
    return _random.nextBool() ? 6 : 8;
  }

  /// Return a random 'counter' for OTP accounts, between 0 and 199.
  int getRandomOtpCounter() {
    return _random.nextInt(200);
  }

  /// Return random 'period' for OTP accounts. 30 or 60.
  int getRandomOtpPeriod() {
    return _random.nextBool() ? 30 : 60;
  }

  /// Return random 'approved' for Notification as integer value. 0 or 1.
  int getRandomNotificationApproval() {
    return _random.nextInt(2);
  }

  /// Return random 'pending' for Notification as integer value. 0 or 1.
  int getRandomNotificationPendingStatus() {
    return _random.nextInt(2);
  }

  /// Return a random with size provided.
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _randomChars.codeUnitAt(_random.nextInt(_randomChars.length))));


  /// Return random UUID.
  String getRandomUUID() {
    return const Uuid().v4();
  }

  /// Return random date for given start year and optional end year.
  DateTime getRandomDate(int startYear, [int endYear]) {
    // if no end year provided, add 2 to currentYear
    endYear ??= DateTime.now().year + 2;
    if (endYear < startYear) {
      throw ArgumentError('Start year cannot be less then end year');
    }
    // when start and end year are equal, add one to end year if not leapYear
    if (startYear == endYear) {
      if (_isLeapYear(startYear)) {
        throw ArgumentError('Start and nnd year cannot be same when leap years are excluded');
      } else {
        endYear += 1;
      }
    }
    // generate random year, month, and day
    final int year = _randomYear(startYear, endYear, false);
    final int month = _random.nextInt(12) + 1;
    final int day = _random.nextInt(_maxDays(year, month));
    final int hour = _random.nextInt(24);
    final int minute = _random.nextInt(60);
    final int second = _random.nextInt(60);

    return DateTime(year, month, day, hour, minute, second);
  }

  /// Return a random bool value.
  bool getRandomBool() => _random.nextBool();

  /// Return a random integer within a specified range (min, max).
  int getRandomInt(int min, int max) => min + _random.nextInt((max + 1) - min);

  /// Generate random year for given range and flag to include/exclude leap years.
  int _randomYear(int startYear, int endYear, bool excludeLeapYear) {
    var _year = startYear + _random.nextInt(endYear - startYear);
    if (excludeLeapYear) {
      while (_isLeapYear(_year)) {
        _year = startYear + _random.nextInt(endYear - startYear);
      }
    }
    return _year;
  }

  /// Return the max number of days for a given year and month.
  int _maxDays(int year, int month) {
    final List<int> maxDaysMonthList = <int>[4, 6, 9, 11];
    if (month == 2) {
      return _isLeapYear(year) ? 29 : 28;
    } else {
      return maxDaysMonthList.contains(month) ? 30 : 31;
    }
  }

  /// Is a leap year.
  bool _isLeapYear(int year) =>
      (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
}
