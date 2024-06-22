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
  /// Метод анализирует системные настройки и возвращает один из поддерживаемых языков,
  /// указанных в перечислении `AppLanguageType`.
  /// - Returns: Текущий язык приложения как значение перечисления `AppLanguageType`.
  func getCurrentLanguage() -> AppLanguageType
  
  /// Возвращает статус включения кода доступа.
  /// - Parameter completion: Замыкание, которое принимает значение `true`, если код доступа включен, и `false`, если отключен.
  func getIsAccessCodeEnabled(completion: ((_ isEnabled: Bool) -> Void)?)
  
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
  
  /// Получает адрес onion-сервиса.
  /// - Returns: Адрес сервиса или ошибка.
  func getOnionAddress(completion: ((Result<String, TorServiceError>) -> Void)?)
}

/// Интерактор
final class SettingsScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: SettingsScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let systemService: ISystemService
  private let modelHandlerService: IMessengerModelHandlerService
  private let notificationService: INotificationService
  private let p2pChatManager: IP2PChatManager
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    systemService = services.userInterfaceAndExperienceService.systemService
    modelHandlerService = services.messengerService.modelHandlerService
    notificationService = services.userInterfaceAndExperienceService.notificationService
    p2pChatManager = services.messengerService.p2pChatManager
  }
}

// MARK: - SettingsScreenInteractorInput

extension SettingsScreenInteractor: SettingsScreenInteractorInput {
  func getOnionAddress(completion: ((Result<String, TorServiceError>) -> Void)?) {
//    p2pChatManager.getOnionAddress(completion: completion)
  }
  
  func copyToClipboard(text: String) {
    systemService.copyToClipboard(text: text)
  }
  
  func showNotification(_ type: SKAbstractions.NotificationServiceType) {
    notificationService.showNotification(type)
  }
  
  func getAppVersion() -> String {
    systemService.getAppVersion()
  }
  
  func getIsAccessCodeEnabled(completion: ((_ isEnabled: Bool) -> Void)?) {
    modelHandlerService.getAppSettingsModel { appSettingsModel in
      completion?(appSettingsModel.appPassword != nil)
    }
  }
  
  func getCurrentLanguage() -> AppLanguageType {
    systemService.getCurrentLanguage()
  }
}

// MARK: - Private

private extension SettingsScreenInteractor {}

// MARK: - Constants

private enum Constants {}
