//
//  Project+InfoPlist.swift
//  ProjectDescriptionHelpers
//
//  Created by Vitalii Sosin on 11.08.2023.
//

import Foundation
import ProjectDescription

public func getMainIOSInfoPlist() -> ProjectDescription.InfoPlist {
  return .dictionary([
    "MARKETING_VERSION": .string("\(marketingVersion)"),
    "CFBundleShortVersionString": .string("\(marketingVersion)"),
    "CFBundleVersion": .string("\(currentProjectVersion)"),
    "CURRENT_PROJECT_VERSION": .string("\(currentProjectVersion)"),
    "PRODUCT_BUNDLE_IDENTIFIER": .string("com.sosinvitalii.Example"),
    "DISPLAY_NAME": .string("Example"),
    "UISupportsDocumentBrowser": .boolean(true),
    "CFBundleAllowMixedLocalizations": .boolean(true),
    "NSUserTrackingUsageDescription": .string("We use user data to provide more personalized content and improve your app experience."),
    "IPHONEOS_DEPLOYMENT_TARGET": .string("16.0"),
    "CFBundleExecutable": .string("Example"),
    "TAB_WIDTH": .string("2"),
    "INDENT_WIDTH": .string("2"),
    "LSSupportsOpeningDocumentsInPlace": .boolean(true),
    "CODE_SIGN_STYLE": .string("Automatic"),
    "ENABLE_BITCODE": .string("NO"),
    "CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED": .string("YES"),
    "ENABLE_TESTABILITY": .string("YES"),
    "VALID_ARCHS": .string("arm64"),
    "DTPlatformVersion": .string("16.0"),
    "CFBundleName": .string("Example"),
    "CFBundleDisplayName": .string("Example"),
    "CFBundleIdentifier": .string("com.sosinvitalii.Example"),
    "LSApplicationCategoryType": .string("public.app-category.utilities"),
    "ITSAppUsesNonExemptEncryption": .boolean(false),
    "TARGETED_DEVICE_FAMILY": .string("1,2"),
    "UIRequiresFullScreen": .boolean(true),
    "UILaunchStoryboardName": .string("LaunchScreen.storyboard"),
    "UIApplicationSupportsIndirectInputEvents": .boolean(true),
    "CFBundlePackageType": .string("APPL"),
    "NSCameraUsageDescription": .string("Please provide access to the Camera"),
    "NSAccentColorName": .string("AccentColor"),
    "CFBundleInfoDictionaryVersion": .string("6.0"),
    "NSPhotoLibraryUsageDescription": .string("Please provide access to the Photo Library"),
    "DTXcode": .integer(1420),
    "LSRequiresIPhoneOS": .boolean(true),
    "DTCompiler": .string("com.apple.compilers.llvm.clang.1_0"),
    "UIStatusBarStyle": .string("UIStatusBarStyleLightContent"),
    "CFBundleDevelopmentRegion": .string("en"),
    "DTSDKBuild": .string("20C52"),
    "DTPlatformBuild": .string("20C52"),
    "UIApplicationSceneManifest": .dictionary([
      "UIApplicationSupportsMultipleScenes": .boolean(false),
      "UISceneConfigurations": .dictionary([
        "UIWindowSceneSessionRoleApplication": .array([
          .dictionary([
            "UISceneConfigurationName": .string("Default Configuration"),
            "UISceneDelegateClassName": .string("Example.SceneDelegate")
          ])
        ])
      ])
    ]),
    "DTPlatformName": .string("iphoneos"),
    "DTXcodeBuild": .string("14C18"),
    "NSPhotoLibraryAddUsageDescription": .string("Please provide access to the Photo Library"),
    "UISupportedInterfaceOrientations~ipad": .array([
      .string("UIInterfaceOrientationPortrait")
    ]),
    "UISupportedInterfaceOrientations": .array([
      .string("UIInterfaceOrientationPortrait")
    ]),
    "UIStatusBarHidden": .boolean(false)
  ])
}
