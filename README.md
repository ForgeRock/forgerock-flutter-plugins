
<p align="center">
  <a href="https://github.com/ForgeRock">
    <img src="https://www.forgerock.com/themes/custom/forgerock/images/fr-logo-horz-color.svg" alt="Logo">
  </a>
  <center>
    <h2>ForgeRock Flutter Plugins</h2>
  </center>
  <p align="center">
    <a href="#support">Support</a>
    ·
    <a href="#documentation" target="_blank">Docs</a>
  </p>
  <hr/>
</p>

<!-- Use the Plugins to leverage _[Intelligent Authentication](https://www.forgerock.com/platform/access-management/intelligent-authentication)_ in [ForgeRock's Access Management (AM)](https://www.forgerock.com/platform/access-management) product, to easily step through each stage of an authentication tree by using callbacks or include MFA capabilies into your app. -->

This repository contains the source code of the Flutter Plugins developed based on the existing native ForgeRock SDKs for [iOS](https://github.com/ForgeRock/forgerock-ios-sdk) and [Android](https://github.com/ForgeRock/forgerock-android-sdk). Each plugin also includes a sample project to help demonstrate the plugin functionality.

The ForgeRock Flutter Plugins enables you to quickly integrate the [ForgeRock Identity Platform](https://www.forgerock.com/digital-identity-and-access-management-platform) into your apps.

## Plugins
These are the available plugins in this repository.

| Plugin | Android | iOS | MacOS | Web | Linux | Windows |
|--------|---------|-----|-------|-----|-------|---------|
| [forgerock-authenticator](./forgerock-authenticator/)|   ✔️  |   ✔️   |  |  |  |  |

## Requirements

* ForgeRock Identity Platform
    * Access Management (AM) 6.5.2
* Android API level 23+
* iOS 11 and above
* Flutter SDK 2.10.x and above

## Documentation

Documentation for the native SDKs is provided at **<https://sdks.forgerock.com>**, and includes topics such as:

* Introducing the SDK Features
* Preparing AM for use with the SDKs
* API Reference documentation

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
