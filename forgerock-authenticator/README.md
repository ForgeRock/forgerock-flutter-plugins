
<p align="center">
  <a href="https://github.com/ForgeRock">
    <img src="https://www.forgerock.com/themes/custom/forgerock/images/fr-logo-horz-color.svg" alt="Logo">
  </a>
  <center>
    <h2>Forgerock Authenticator Plugin</h2>
  </center>
  <p align="center">
    <a href="./CHANGELOG.md">Change Log</a>
    ·
    <a href="#support">Support</a>
    ·
    <a href="#documentation" target="_blank">Docs</a>
  </p>
  <hr/>
</p>

The **ForgeRock Authenticator Plugin** enables you to build the power of the official ForgeRock Authenticator application into your own app with ease.

The Authenticator module supports:

- Time-based one-time passwords (TOTP)
- HMAC-based one-time password (HOTP)
- Push notifications

This project is provided as a Flutter plugin, a specialized package that includes platform-specific implementation code and utilizes the Authenticator module of our native SDK for [iOS](https://github.com/ForgeRock/forgerock-ios-sdk) and [Android](https://github.com/ForgeRock/forgerock-android-sdk). It also includes the Authenticator app as a sample project to help demonstrate the SDK functionality. The sample contains most of the functionalities available on the offical ForgeRock Authenticator app.

> The sample app included in this repository is an open source fork of the ForgeRock Authenticator app available on the [Google Play Store](https://play.google.com/store/apps/details?id=com.forgerock.authenticator) and [Apple App Store](https://apps.apple.com/us/app/forgerock-authenticator/id1038442926). The supported version of the app still remains proprietary. There is no guarantee that this open source app will receive any changes made on the official version. Issues here are answered by maintainers and other community members on a best-effort basis.

## Requirements

* ForgeRock Identity Platform
  * Access Management (AM) 6.5.2
* Android API level 21+
* iOS 10 and above
* Flutter SDK 2.10.x and above

## Installation

```groovy
dependencies:
    forgerock_authenticator:
      git:
          url: git://https://github.com/ForgeRock/forgerock-flutter-plugins.git
          path: forgerock_authenticator
```

## Getting Started

### Android

To try out the ForgeRock Android SDK sample, perform these steps:

1. Setup an Access Management (AM) instance for [OATH](https://backstage.forgerock.com/docs/am/7/authentication-guide/authn-mfa-about-oath.html) or [Push](https://backstage.forgerock.com/docs/am/7/authentication-guide/authn-mfa-about-push.html).
2. Clone this repo
3. Open the Android project `forgerock-authenticator/example/android` in [Android Studio](https://developer.android.com/studio).
4. Add your `google-services.json` to the `app` folder.
5. On the **Run** menu, click **Run 'app'**.

### iOS
To try out the ForgeRock Authenticator iOS sample app, perform these steps:

1. Setup an Access Management (AM) instance for [OATH](https://backstage.forgerock.com/docs/am/7/authentication-guide/authn-mfa-about-oath.html) or [Push](https://backstage.forgerock.com/docs/am/7/authentication-guide/authn-mfa-about-push.html).
2. Clone this repo
3. Open the `forgerock-authenticator/example/ios/Runner.xcworkspace` file in [Xcode](https://developer.apple.com/xcode/).
4. Update the your XCode project with your settings (Provisioning Profile, Certificates, ...)
5. Ensure the active scheme is "_Runner_", and then click the **Run** button.

## Support

If you encounter any issues, be sure to check our **[Troubleshooting](https://backstage.forgerock.com/knowledge/kb/article/a79362752)** pages.

Support tickets can be raised whenever you need our assistance; here are some examples of when it is appropriate to open a ticket (but not limited to):

* Suspected bugs or problems with ForgeRock software.
* Requests for assistance - please look at the **[Documentation](https://sdks.forgerock.com)** and **[Knowledge Base](https://backstage.forgerock.com/knowledge/kb/home/g32324668)** first.

You can raise a ticket using **[BackStage](https://backstage.forgerock.com/support/tickets)**, our customer support portal that provides one stop access to ForgeRock services.

BackStage shows all currently open support tickets and allows you to raise a new one by clicking **New Ticket**.

## Contributing

If you would like to contribute to this project you can fork the repository, clone it to your machine and get started.

## Disclaimer

> This code is provided by ForgeRock on an “as is” basis, without warranty of any kind, to the fullest extent permitted by law. ForgeRock does not represent or warrant or make any guarantee regarding the use of this code or the accuracy, timeliness or completeness of any data or information relating to this code, and ForgeRock hereby disclaims all warranties whether express, or implied or statutory, including without limitation the implied warranties of merchantability, fitness for a particular purpose, and any warranty of non-infringement. ForgeRock shall not have any liability arising out of or related to any use, implementation or configuration of this code, including but not limited to use for any commercial purpose. Any action or suit relating to the use of the code may be brought only in the courts of a jurisdiction wherein ForgeRock resides or in which ForgeRock conducts its primary business, and under the laws of that jurisdiction excluding its conflict-of-law provisions.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
