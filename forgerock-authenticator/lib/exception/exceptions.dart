/*
 * Copyright (c) 2022-2023 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

/// Exception thrown when a Mechanism was already registered
class DuplicateMechanismException implements Exception {
  late String _message;

  DuplicateMechanismException(
      [String message = 'This authentication method is already registered.']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

/// Exception thrown when an error in setting up a mechanism.
class MechanismCreationException implements Exception {
  late String _message;

  MechanismCreationException([String? message]) {
    if (message != null) {
      this._message = 'Error registering new MFA account:\n $message';
    } else {
      this._message = 'Error registering new MFA account.';
    }
  }

  @override
  String toString() {
    return _message;
  }
}

/// Exception thrown when an error occur on processing Push Authentication.
class HandleNotificationException implements Exception {
  late String _message;

  HandleNotificationException([String? message]) {
    if (message != null) {
      this._message =
          'Error processing Push Authentication request:\n $message';
    } else {
      this._message = 'Error processing Push Authentication request.';
    }
  }

  @override
  String toString() {
    return _message;
  }
}

/// Exception thrown when an action is invoked for a locked Account.
class AccountLockException implements Exception {
  late String _message;

  AccountLockException([String? message]) {
    if (message != null) {
      this._message =
      'Account is locked:\n $message';
    } else {
      this._message = 'This action cannot be performed. Account is locked.';
    }
  }

  @override
  String toString() {
    return _message;
  }
}

/// Exception thrown when an Account cannot be registered due policy violation.
class PolicyViolationException implements Exception {
  late String _message;

  PolicyViolationException([String message = 'The account cannot be registered on this device. It violates some policy']) {
      this._message = message;
  }

  @override
  String toString() {
    return _message;
  }

  // TODO: Change this method to return data from a new _policyName field
  String? getPolicyName() {
    int index = _message.indexOf(':');
    if (index != 0) {
      return _message.substring(index+1, _message.length).trim();
    } else {
      return null;
    }
  }
}