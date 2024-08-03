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
  
  private let modelHandlerService: IMessengerModelHandlerService
  private let systemService: ISystemService
  private let notificationService: INotificationService
  
  // MARK: - Init
  
  public init(
    modelHandlerService: IMessengerModelHandlerService,
    systemService: ISystemService,
    notificationService: INotificationService
  ) {
    self.modelHandlerService = modelHandlerService
    self.systemService = systemService
    self.notificationService = notificationService
  }
  
  // MARK: - Public properties
  
  public func getAppSettingsModel() async -> AppSettingsModel {
    return await modelHandlerService.getAppSettingsModel()
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
