//
//  SuggestScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol SuggestScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol SuggestScreenInteractorInput {
  /// Запрос доступа к Уведомлениям
  /// - Parameter granted: Булево значение, указывающее, было ли предоставлено разрешение
  func requestNotification() async -> Bool
  
  /// Метод для проверки, включены ли уведомления
  func isNotificationsEnabled() async -> Bool
  
  /// Получает модель настроек приложения `AppSettingsModel` асинхронно.
  func getAppSettingsModel() async -> AppSettingsModel
  
  /// Включает или отключает уведомления в приложении.
  /// - Parameters:
  ///   - value: Значение, указывающее, следует ли включить уведомления.
  func setIsEnabledNotifications(_ value: Bool) async
}

/// Интерактор
final class SuggestScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: SuggestScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let permissionService: IPermissionService
  private let appSettingsDataManager: IAppSettingsDataManager
  
  /// - Parameters:
  ///   - services: Сервисы
  init(services: IApplicationServices) {
    self.permissionService = services.accessAndSecurityManagementService.permissionService
    self.appSettingsDataManager = services.messengerService.appSettingsDataManager
  }
}

// MARK: - SuggestScreenInteractorInput

extension SuggestScreenInteractor: SuggestScreenInteractorInput {
  func isNotificationsEnabled() async -> Bool {
    await permissionService.isNotificationsEnabled()
  }
  
  func requestNotification() async -> Bool {
    await permissionService.requestNotification()
  }
  
  func getAppSettingsModel() async -> AppSettingsModel {
    await appSettingsDataManager.getAppSettingsModel()
  }
  
  func setIsEnabledNotifications(_ value: Bool) async {
    await appSettingsDataManager.setIsEnabledNotifications(value)
  }
}

// MARK: - Private

private extension SuggestScreenInteractor {}

// MARK: - Constants

private enum Constants {}
