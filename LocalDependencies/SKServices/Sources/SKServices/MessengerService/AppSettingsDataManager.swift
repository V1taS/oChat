//
//  AppSettingsDataManager.swift
//  SKServices
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import Foundation
import SwiftUI
import SKAbstractions
import SKStyle

// MARK: - AppSettingsDataManager

public final class AppSettingsDataManager: IAppSettingsDataManager {
  
  // MARK: - Public properties
  
  public static let shared = AppSettingsDataManager()
  
  // MARK: - Private properties
  
  private var appSettingsData = SecureDataManagerService(.appSettingsData)
  private let queueAppSettings = DispatchQueue(label: "com.sosinvitalii.AppSettingsDataQueue")
  
  // MARK: - Init
  
  private init() {}
  
  public func getAppSettingsModel() async -> AppSettingsModel {
    await withCheckedContinuation { continuation in
      queueAppSettings.async { [weak self] in
        guard let self else { return }
        let messengerModel: AppSettingsModel
        if let model: AppSettingsModel? = self.appSettingsData.getModel(for: Constants.appSettingsManagerKey),
           let unwrappedModel = model {
          messengerModel = unwrappedModel
        } else {
          messengerModel = AppSettingsModel.setDefaultValues()
        }
        continuation.resume(returning: messengerModel)
      }
    }
  }

  public func saveAppSettingsModel(_ model: AppSettingsModel) async {
    await withCheckedContinuation { continuation in
      queueAppSettings.async { [weak self] in
        guard let self else { return }
        self.appSettingsData.saveModel(model, for: Constants.appSettingsManagerKey)
        continuation.resume()
      }
    }
  }
  
  @discardableResult
  public func deleteAllData() -> Bool {
    appSettingsData.deleteAllData()
  }
  
  public func setAppPassword(_ value: String?) async {
    var model = await getAppSettingsModel()
    model.appPassword = value
    await saveAppSettingsModel(model)
  }
  
  public func setFakeAppPassword(_ value: String?) async {
    var model = await getAppSettingsModel()
    model.fakeAppPassword = value
    await saveAppSettingsModel(model)
  }
  
  public func setAccessType(_ accessType: AppSettingsModel.AccessType) async {
    var model = await getAppSettingsModel()
    model.accessType = accessType
    await saveAppSettingsModel(model)
  }
  
  public func setIsPremiumEnabled(_ value: Bool) async {
    var model = await getAppSettingsModel()
    model.isPremiumEnabled = value
    await saveAppSettingsModel(model)
  }
  
  public func setIsTypingIndicatorEnabled(_ value: Bool) async {
    var model = await getAppSettingsModel()
    model.isTypingIndicatorEnabled = value
    await saveAppSettingsModel(model)
  }
  
  public func setCanSaveMedia(_ value: Bool) async {
    var model = await getAppSettingsModel()
    model.canSaveMedia = value
    await saveAppSettingsModel(model)
  }
  
  public func setIsChatHistoryStored(_ value: Bool) async {
    var model = await getAppSettingsModel()
    model.isChatHistoryStored = value
    await saveAppSettingsModel(model)
  }
  
  public func setIsVoiceChangerEnabled(_ value: Bool) async {
    var model = await getAppSettingsModel()
    model.isVoiceChangerEnabled = value
    await saveAppSettingsModel(model)
  }
  
  public func setIsEnabledNotifications(_ value: Bool) async {
    var model = await getAppSettingsModel()
    model.isNotificationsEnabled = value
    await saveAppSettingsModel(model)
  }
  
  public func saveMyPushNotificationToken(_ token: String) async {
    var model = await getAppSettingsModel()
    model.pushNotificationToken = token
    await saveAppSettingsModel(model)
  }
  
  public func setToxStateAsString(_ toxStateAsString: String?) async {
    var model = await getAppSettingsModel()
    model.toxStateAsString = toxStateAsString
    await saveAppSettingsModel(model)
  }
}

// MARK: - Constants

private enum Constants {
  static let appSettingsManagerKey = String(describing: AppSettingsDataManager.self)
}
