//
//  Copyright (c) 2022 ForgeRock. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "ForgerockAuthenticatorPlugin.h"
#if __has_include(<forgerock_authenticator/forgerock_authenticator-Swift.h>)
#import <forgerock_authenticator/forgerock_authenticator-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "forgerock_authenticator-Swift.h"
#endif

@implementation ForgerockAuthenticatorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftForgerockAuthenticatorPlugin registerWithRegistrar:registrar];
}
@end
