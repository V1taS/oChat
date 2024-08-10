//
//  SettingsScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol SettingsScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol SettingsScreenInteractorInput {
  /// Возвращает текущий язык приложения.
  func getCurrentLanguage() -> AppLanguageType
  
  /// Возвращает текущую версию приложения.
  /// - Returns: Строка с версией приложения, например, "1.0".
  func getAppVersion() -> String
  
  /// Копирует текст в буфер обмена.
  /// - Parameters:
  ///   - text: Текст для копирования.
  func copyToClipboard(text: String)
  
  /// Показать уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  func showNotification(_ type: NotificationServiceType)
  
  /// Удалить все данные из основной модели
  @discardableResult
  func deleteAllData() async -> Bool
  
  /// Получить модель настроек приложения
  /// - Returns: Асинхронная операция, возвращающая модель настроек `AppSettingsModel`
  func getAppSettingsModel() async -> AppSettingsModel
}

/// Интерактор
final class SettingsScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: SettingsScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let systemService: ISystemService
  private let notificationService: INotificationService
  private let p2pChatManager: IP2PChatManager
  private let appSettingsDataManager: IAppSettingsDataManager
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    systemService = services.userInterfaceAndExperienceService.systemService
    notificationService = services.userInterfaceAndExperienceService.notificationService
    p2pChatManager = services.messengerService.p2pChatManager
    appSettingsDataManager = services.messengerService.appSettingsDataManager
  }
}

// MARK: - SettingsScreenInteractorInput

extension SettingsScreenInteractor: SettingsScreenInteractorInput {
  func getAppSettingsModel() async -> SKAbstractions.AppSettingsModel {
    await appSettingsDataManager.getAppSettingsModel()
  }
  
  func deleteAllData() async -> Bool {
    appSettingsDataManager.deleteAllData()
  }
  
  func copyToClipboard(text: String) {
    systemService.copyToClipboard(text: text)
  }
  
  func showNotification(_ type: NotificationServiceType) {
    notificationService.showNotification(type)
  }
  
  func getAppVersion() -> String {
    systemService.getAppVersion()
  }
  
  func getCurrentLanguage() -> AppLanguageType {
    systemService.getCurrentLanguage()
  }
}

// MARK: - Private

private extension SettingsScreenInteractor {}

// MARK: - Constants

private enum Constants {}
