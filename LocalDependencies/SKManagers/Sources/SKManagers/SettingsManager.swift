//
//  SettingsManager.swift
//  SKManagers
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle
import SKFoundation

public final class SettingsManager: ISettingsManager {
  
  // MARK: - Private properties
  
  private let systemService: ISystemService
  private let notificationService: INotificationService
  private let appSettingsDataManager: IAppSettingsDataManager
  
  // MARK: - Init
  
  public init(
    appSettingsDataManager: IAppSettingsDataManager,
    systemService: ISystemService,
    notificationService: INotificationService
  ) {
    self.appSettingsDataManager = appSettingsDataManager
    self.systemService = systemService
    self.notificationService = notificationService
  }
  
  // MARK: - Public properties
  
  public func getAppSettingsModel() async -> AppSettingsModel {
    return await appSettingsDataManager.getAppSettingsModel()
  }
  
  public func passcodeNotSetInSystemIOSCheck(errorMessage: String) async {
    let result = await systemService.checkIfPasscodeIsSet()
    if case let .failure(error) = result, error == .passcodeNotSet {
      await MainActor.run {
        notificationService.showNotification(
          .negative(
            title: errorMessage
          )
        )
      }
    }
  }
}
