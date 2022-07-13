/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

const String hotpURI = "otpauth://hotp/issuer1:user1?secret=ONSWG4TFOQ=====&counter=10&digits=8";

const String hotpMechanismJson = "{" +
    "\"id\":\"issuer1-user1-otpauth\"," +
    "\"issuer\":\"issuer1\"," +
    "\"accountName\":\"user1\"," +
    "\"mechanismUID\":\"c112b325-ac22-37f1-aae6-c12cf411cf80\"," +
    "\"secret\":\"REMOVED\"," +
    "\"type\":\"otpauth\"," +
    "\"oathType\":\"HOTP\"," +
    "\"algorithm\":\"sha256\"," +
    "\"digits\":8," +
    "\"counter\":\"10\"" +
    "}";

const String totpURI = "otpauth://totp/issuer1:user1?secret=ADADADAD=====&period=30&digits=6";

const String totpMechanismJson = "{" +
    "\"id\":\"issuer1-user1-otpauth\"," +
    "\"issuer\":\"issuer1\"," +
    "\"accountName\":\"user1\"," +
    "\"mechanismUID\":\"b162b325-ebb1-48e0-8ab7-b38cf341da95\"," +
    "\"secret\":\"REMOVED\"," +
    "\"type\":\"otpauth\"," +
    "\"oathType\":\"TOTP\"," +
    "\"algorithm\":\"sha1\"," +
    "\"digits\":6," +
    "\"period\":30" +
    "}";

const String pushMechanismJson = "{" +
    "\"id\":\"issuer1-user1-pushauth\"," +
    "\"issuer\":\"issuer1\"," +
    "\"accountName\":\"user1\"," +
    "\"mechanismUID\":\"0585ace6-6e91-42bb-9a65-2f48f5212a20\"," +
    "\"secret\":\"REMOVED\"," +
    "\"type\":\"pushauth\"," +
    "\"registrationEndpoint\":\"https://example.com/am/json/push/sns/message?_action=register\"," +
    "\"authenticationEndpoint\":\"https://example.com/am/json/push/sns/message?_action=authenticate\"" +
    "}";

const String accountJson = "{" +
    "\"id\":\"issuer1-user1\"," +
    "\"issuer\":\"issuer1\"," +
    "\"accountName\":\"user1\"," +
    "\"imageURL\":\"http:\\/\\/forgerock.com\\/logo.jpg\"," +
    "\"backgroundColor\":\"032b75\"," +
    "\"timeAdded\":100000" +
    "}";

const String accountWithOathMechanismJson = "{" +
    "\"id\":\"issuer1-user1\"," +
    "\"issuer\":\"issuer1\"," +
    "\"accountName\":\"user1\"," +
    "\"imageURL\":\"http:\\/\\/forgerock.com\\/logo.jpg\"," +
    "\"backgroundColor\":\"032b75\"," +
    "\"timeAdded\":100000," +
    "\"mechanismList\":[" + totpMechanismJson +
    "]}";

const String accountWithPushMechanismJson = "{" +
    "\"id\":\"issuer1-user1\"," +
    "\"issuer\":\"issuer1\"," +
    "\"accountName\":\"user1\"," +
    "\"imageURL\":\"http:\\/\\/forgerock.com\\/logo.jpg\"," +
    "\"backgroundColor\":\"032b75\"," +
    "\"timeAdded\":100000," +
    "\"mechanismList\":[" + pushMechanismJson +
    "]}";

const String accountWithPushAndOathMechanismsJson = "{" +
    "\"id\":\"issuer1-user1\"," +
    "\"issuer\":\"issuer1\"," +
    "\"accountName\":\"user1\"," +
    "\"imageURL\":\"http:\\/\\/forgerock.com\\/logo.jpg\"," +
    "\"backgroundColor\":\"032b75\"," +
    "\"timeAdded\":100000," +
    "\"mechanismList\":[" + pushMechanismJson + "," + totpMechanismJson +
    "]}";

const String pushNotificationJson = "{" +
    "\"id\":\"0585ace6-6e91-42bb-9a65-2f48f5212a20-100000\"," +
    "\"mechanismUID\":\"0585ace6-6e91-42bb-9a65-2f48f5212a20\"," +
    "\"messageId\":\"AUTHENTICATE:63ca6f18-7cfb-4198-bcd0-ac5041fbbea01583798229441\"," +
    "\"challenge\":\"fZl8wu9JBxdRQ7miq3dE0fbF0Bcdd+gRETUbtl6qSuM=\"," +
    "\"amlbCookie\":\"ZnJfc3NvX2FtbGJfcHJvZD0wMQ==\"," +
    "\"ttl\":120," +
    "\"timeAdded\":100000," +
    "\"timeExpired\":120000," +
    "\"approved\":false," +
    "\"pending\":true}";

const String challengePushNotificationJson = '{'
    '\"id\":\"0c43c695-8d67-47f1-b575-1c7a83512060-1657238273273\",'
    '\"mechanismUID\":\"0c43c695-8d67-47f1-b575-1c7a83512060\",'
    '\"messageId\":\"AUTHENTICATE:2b43a378-0013-4589-8e81-118be10559ac1657238273273\",'
    '\"message\":\"Login attempt from user0 at ForgeRock-72\",'
    '\"challenge\":\"23RD41+UyKFZ77Am3Pu5Oxm7L3lu6CB+IhT3ZN4KzQo=\",'
    '\"amlbCookie\":\"amlbcookie=01\",'
    '\"timeAdded\":1657238273273,'
    '\"timeExpired\":1657238393273,'
    '\"ttl\":120,'
    '\"approved\":false,\"pending\":true,'
    '\"customPayload\":\"{  }\",'
    '\"contextInfo\":\"{ \\"location\\": { \\"latitude\\": 49.2306432, \\"longitude\\": -123.1126528 }, \\"remoteIp\\": \\"192.168.1.1\\", \\"userAgent\\": \\"Mozilla\/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/102.0.0.0 Safari\/537.36\\" }\",'
    '\"pushType\":\"challenge\",'
    '\"numbersChallenge\":\"27,64,71\"}';

const String biometricPushNotificationJson = '{'
    '\"id\":\"0c43c695-8d67-47f1-b575-1c7a83512060-1657238273273\",'
    '\"mechanismUID\":\"0c43c695-8d67-47f1-b575-1c7a83512060\",'
    '\"messageId\":\"AUTHENTICATE:2b43a378-0013-4589-8e81-118be10559ac1657238273273\",'
    '\"message\":\"Login attempt from user0 at ForgeRock-72\",'
    '\"challenge\":\"23RD41+UyKFZ77Am3Pu5Oxm7L3lu6CB+IhT3ZN4KzQo=\",'
    '\"amlbCookie\":\"amlbcookie=01\",'
    '\"timeAdded\":1657238273273,'
    '\"timeExpired\":1657238393273,'
    '\"ttl\":120,'
    '\"approved\":false,\"pending\":true,'
    '\"customPayload\":\"{  }\",'
    '\"contextInfo\":\"{ \\"location\\": { \\"latitude\\": 49.2306432, \\"longitude\\": -123.1126528 }, \\"remoteIp\\": \\"192.168.1.1\\", \\"userAgent\\": \\"Mozilla\/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/102.0.0.0 Safari\/537.36\\" }\",'
    '\"pushType\":\"biometric\",'
    '\"numbersChallenge\":null}';

const String apnsPayload = '{ "aps": { "category": "authentication","messageId": "AUTHENTICATE:63ca6f18-7cfb-4198-bcd0-ac5041fbbea01583798229441","content-available": 1, "interruption-level": "time-sensitive" , "alert": "Login attempt from user1 at issuer1", "sound": "default", "data": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJjIjoiRER3cE1EOFlEY2YvSmRaL2pBU3diZFRCNkJBOFhDaEFSNkJTc3hHa2J5ND0iLCJ0IjoiMTIwIiwidSI6IjE4OUNBMDY5LUU0MkQtNEZCQS05QTVELUVCMEYxQkQyOUU0MyIsImwiOiJZVzFzWW1OdmIydHBaVDB3TVE9PSJ9.qcXHvnPrISm58iFt2W_nZPULfDhGz4f4KSidZhNvQHg"}}';

const String oathTokenCodeJson = "{\"oathType\":\"HOTP\",\"code\":\"123456\",\"start\":10000,\"until\":10030}";
