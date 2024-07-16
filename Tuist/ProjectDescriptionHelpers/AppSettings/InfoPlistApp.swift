//
//  InfoPlistApp.swift
//  ProjectDescriptionHelpers
//
//  Created by Vitalii Sosin on 04.03.2024.
//

import ProjectDescription

public extension InfoPlist {
  private static var common: [String: Plist.Value] {
    [
      "UILaunchStoryboardName": .string("LaunchScreen.storyboard"),
      "CFBundleShortVersionString": .string("$(MARKETING_VERSION)"),
      "CFBundleVersion": .string("$(CURRENT_PROJECT_VERSION)"),
      "PRODUCT_BUNDLE_IDENTIFIER": .string("\(Constants.bundleApp)"),
      "IPHONEOS_DEPLOYMENT_TARGET": .string("\(Constants.iOSTargetVersion)"),
      "DEVELOPMENT_TEAM": .string("\(Constants.developmentTeam)"),
      "CODE_SIGN_STYLE": .string("Automatic"),
      "CODE_SIGN_IDENTITY": "iPhone Developer",
      "VALID_ARCHS": .string("arm64"),
      "DTPlatformVersion": .string("\(Constants.iOSTargetVersion)"),
      "DTPlatformName": .string("iphoneos"),
      "TARGETED_DEVICE_FAMILY": .string("1,2"),
      "CFBundleLocalizations": .array([
        .string("en"),
        .string("ru")
      ]),
      "UIRequiresFullScreen": .boolean(true),
      "ITSAppUsesNonExemptEncryption": .boolean(false),
      "CFBundlePackageType": .string("APPL"),
      "UISupportedInterfaceOrientations~ipad": .array([
        .string("UIInterfaceOrientationPortrait")
      ]),
      "UISupportedInterfaceOrientations": .array([
        .string("UIInterfaceOrientationPortrait")
      ]),
      "NSPhotoLibraryUsageDescription": .string("Grant access to photo library to be able to select photos"),
      "NSCameraUsageDescription": .string("Grant access to camera to be able to take photos and videos"),
      "NSMicrophoneUsageDescription": .string("Grant access to microphone to be able to take videos")
    ]
  }
  
  static var app: InfoPlist {
    var extendedPlist: [String: Plist.Value] = [
      "MARKETING_VERSION": .string("$(MARKETING_VERSION)"),
      "CFBundleIconName": .string("AppIcon"),
      "CURRENT_PROJECT_VERSION": .string("$(CURRENT_PROJECT_VERSION)"),
      "DISPLAY_NAME": .string("\(Constants.appNameRelease)"),
      "UISupportsDocumentBrowser": .boolean(true),
      "CFBundleAllowMixedLocalizations": .boolean(true),
      "CFBundleExecutable": .string("\(Constants.appNameRelease)"),
      "TAB_WIDTH": .string("2"),
      "INDENT_WIDTH": .string("2"),
      "LSSupportsOpeningDocumentsInPlace": .boolean(true),
      "ENABLE_BITCODE": .string("NO"),
      "CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED": .string("YES"),
      "ENABLE_TESTABILITY": .string("YES"),
      "CFBundleName": .string("\(Constants.appNameRelease)"),
      "CFBundleDisplayName": .string("\(Constants.appDisplayName)"),
      "CFBundleIdentifier": .string("\(Constants.bundleApp)"),
      "LSApplicationCategoryType": .string("public.app-category.finance"),
      "UIApplicationSupportsIndirectInputEvents": .boolean(true),
      "CFBundleInfoDictionaryVersion": .string("6.0"),
      "LSRequiresIPhoneOS": .boolean(true),
      "UIStatusBarStyle": .string("UIStatusBarStyleLightContent"),
      "CFBundleDevelopmentRegion": .string("\(Constants.developmentRegion)"),
      "NSPhotoLibraryAddUsageDescription": .string("Please provide access to the Photo Library"),
      "UIStatusBarHidden": .boolean(false),
      "NSAccentColorName": .string("AccentColor"),
      "NSFaceIDUsageDescription": .string("\(Constants.appNameRelease) requires access to Face ID for quick and secure authentication."),
      "NSCameraUsageDescription": .string("Please provide access to the Camera"),
      "NSPhotoLibraryUsageDescription": .string("Please provide access to the Photo Library"),
      "UIApplicationSceneManifest": .dictionary([
        "UIApplicationSupportsMultipleScenes": .boolean(false),
        "UISceneConfigurations": .dictionary([
          "UIWindowSceneSessionRoleApplication": .array([
            .dictionary([
              "UISceneConfigurationName": .string("Default Configuration"),
              "UISceneDelegateClassName": .string("\(Constants.appNameRelease).SceneDelegate")
            ])
          ])
        ])
      ]),
      "NSAppTransportSecurity": .dictionary([
        "NSAllowsArbitraryLoads": .boolean(true)
      ]),
      "com.apple.developer.associated-domains": .array([
        .string("applinks:\(Constants.appLink)")
      ]),
      // Добавление фоновых режимов
      "UIBackgroundModes": .array([
        .string("audio"),
        .string("voip"),
        .string("fetch")
      ])
    ]
    
    // Добавление кастомной URL схемы
    extendedPlist["CFBundleURLTypes"] = .array([
      .dictionary([
        "CFBundleURLSchemes": .array([.string("\(Constants.appLink)")])
      ])
    ])
    
    extendedPlist.merge(self.common) { current, _ in
      current
    }
    
    return InfoPlist.extendingDefault(with: extendedPlist)
  }
}
