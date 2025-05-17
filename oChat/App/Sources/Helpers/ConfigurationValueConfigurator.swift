//
//  ConfigurationValueConfigurator.swift
//  oChat
//
//  Created by Vitalii Sosin on 14.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import UIKit
import ApphudSDK
import SwiftUICore

final class ConfigurationValueConfigurator {
  static let shared = ConfigurationValueConfigurator()
  private init() {}

  // MARK: - Private properties

  // MARK: - Internal func

  func configure() async {
    let isReachable = NetworkReachabilityService()?.isReachable ?? false
    guard isReachable else {
      return
    }

    Task.detached(priority: .medium) {
      _ = await PermissionService.shared.requestNotification()
    }

    await getPushNotificationAuthKey()
    await getPushNotificationKeyID()
    await getPushNotificationProdURL()
    await getPushNotificationTeamID()
    await getPushNotificationTestURL()

    await getApphud()
    await getAmplitude()

    await getSupportOChatMail()
    await getPremiumList()
  }
}

// MARK: - Private

private extension ConfigurationValueConfigurator {
  func getPremiumList() async {
    if let value = await getConfigurationValue(forKey: Constants.premiumList) {
      guard let jsonData = value.data(using: .utf8) else {
        return
      }
      let premiumList = PremiumModel.decodeFromJSON(jsonData)
      Secrets.premiumList = premiumList
    }
  }

  func getApphud() async {
    if let value = await getConfigurationValue(forKey: Constants.apiKeyApphudKey) {
      DispatchQueue.main.async {
        Apphud.start(apiKey: value)
        let idfv = UIDevice.current.identifierForVendor?.uuidString
        Apphud.setDeviceIdentifiers(idfa: nil, idfv: idfv)
      }
    }
  }

  func getSupportOChatMail() async {
    if let value = await getConfigurationValue(forKey: Constants.supportMail) {
      Secrets.supportMail = value
    }
  }

  func getAmplitude() async {
    if let value = await getConfigurationValue(forKey: Constants.amplitude) {
      Secrets.amplitude = value
    }
  }

  func getPushNotificationAuthKey() async {
    if let value = await getConfigurationValue(forKey: Constants.pushNotificationAuthKey) {
      Secrets.pushNotificationAuthKey = value
    }
  }

  func getPushNotificationKeyID() async {
    if let value = await getConfigurationValue(forKey: Constants.pushNotificationKeyID) {
      Secrets.pushNotificationKeyID = value
    }
  }

  func getPushNotificationProdURL() async {
    if let value = await getConfigurationValue(forKey: Constants.pushNotificationProdURL) {
      Secrets.pushNotificationProdURL = value
    }
  }

  func getPushNotificationTeamID() async {
    if let value = await getConfigurationValue(forKey: Constants.pushNotificationTeamID) {
      Secrets.pushNotificationTeamID = value
    }
  }

  func getPushNotificationTestURL() async {
    if let value = await  getConfigurationValue(forKey: Constants.ushNotificationTestURL) {
      Secrets.pushNotificationTestURL = value
    }
  }

  func getConfigurationValue(forKey key: String, recordTypes: CloudKitRecordTypes = .config) async -> String? {
    try? await CloudKitService.shared.getConfigurationValue(from: key, recordTypes: recordTypes)
  }

  func clearAllUserData() {
    // 1. Очищаем UserDefaults:
    if let bundleIdentifier = Bundle.main.bundleIdentifier {
      UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
      UserDefaults.standard.synchronize()
    }

    // 2. Очищаем данные из Keychain:
    let secItemClasses = [
      kSecClassGenericPassword,
      kSecClassInternetPassword,
      kSecClassCertificate,
      kSecClassKey,
      kSecClassIdentity
    ]

    for itemClass in secItemClasses {
      let query = [kSecClass as String: itemClass]
      SecItemDelete(query as CFDictionary)
    }
  }
}

// MARK: - Private

private enum Constants {
  static let pushNotificationAuthKey = "PushNotificationAuthKey"
  static let pushNotificationKeyID = "PushNotificationKeyID"
  static let pushNotificationProdURL = "PushNotificationProdURL"
  static let pushNotificationTeamID = "PushNotificationTeamID"
  static let ushNotificationTestURL = "PushNotificationTestURL"

  static let supportMail = "SupportOChatMail"
  static let premiumList = "PremiumList"

  static let apiKeyApphudKey = "apiKeyApphud"
  static let amplitude = "amplitude"
}
