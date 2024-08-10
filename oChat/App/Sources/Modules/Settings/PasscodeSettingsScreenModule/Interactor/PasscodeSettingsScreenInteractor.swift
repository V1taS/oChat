//
//  PasscodeSettingsScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol PasscodeSettingsScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol PasscodeSettingsScreenInteractorInput {
  /// Сбрасывает текущий код доступа
  func resetPasscode() async
  
  /// Сбрасывает фейковый код доступа
  func resetFakePasscode() async
  
  /// Получить модель со всеми настройками
  func getAppSettingsModel() async -> AppSettingsModel
  
  /// Устанавливает поддельный пароль приложения.
  /// - Parameter value: Новый поддельный пароль для приложения.
  func setFakeAppPassword(_ value: String?) async
  
  /// Установить доступ в приложение
  /// - Parameter accessType: Тип доступа
  func setAccessType(_ accessType: AppSettingsModel.AccessType) async
  
  /// Включает или отключает премиум доступ.
  /// - Parameter value: Значение, указывающее, следует ли включить премиум доступ.
  func setIsPremiumEnabled(_ value: Bool) async
  
  /// Включает или отключает индикатор набора текста.
  /// - Parameter value: Значение, указывающее, следует ли включить индикатор набора текста.
  func setIsTypingIndicatorEnabled(_ value: Bool) async
  
  /// Включает или отключает возможность сохранения медиафайлов.
  /// - Parameter value: Значение, указывающее, следует ли включить возможность сохранения медиафайлов.
  func setCanSaveMedia(_ value: Bool) async
  
  /// Включает или отключает сохранение истории чата.
  /// - Parameter value: Значение, указывающее, следует ли сохранять историю чата.
  func setIsChatHistoryStored(_ value: Bool) async
  
  /// Включает или отключает изменение голоса.
  /// - Parameter value: Значение, указывающее, следует ли включить изменение голоса.
  func setIsVoiceChangerEnabled(_ value: Bool) async
  
  /// Показать уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  func showNotification(_ type: NotificationServiceType)
}

/// Интерактор
final class PasscodeSettingsScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: PasscodeSettingsScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let permissionService: IPermissionService
  private let notificationService: INotificationService
  private let appSettingsDataManager: IAppSettingsDataManager
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    permissionService = services.accessAndSecurityManagementService.permissionService
    notificationService = services.userInterfaceAndExperienceService.notificationService
    appSettingsDataManager = services.messengerService.appSettingsDataManager
  }
}

// MARK: - PasscodeSettingsScreenInteractorInput

extension PasscodeSettingsScreenInteractor: PasscodeSettingsScreenInteractorInput {
  func showNotification(_ type: SKAbstractions.NotificationServiceType) {
    notificationService.showNotification(type)
  }
  
  func setFakeAppPassword(_ value: String?) async {
    await appSettingsDataManager.setFakeAppPassword(value)
  }
  
  func setAccessType(_ accessType: AppSettingsModel.AccessType) async {
    await appSettingsDataManager.setAccessType(accessType)
  }
  
  func setIsPremiumEnabled(_ value: Bool) async {
    await appSettingsDataManager.setIsPremiumEnabled(value)
  }
  
  func setIsTypingIndicatorEnabled(_ value: Bool) async {
    await appSettingsDataManager.setIsTypingIndicatorEnabled(value)
  }
  
  func setCanSaveMedia(_ value: Bool) async {
    await appSettingsDataManager.setCanSaveMedia(value)
  }
  
  func setIsChatHistoryStored(_ value: Bool) async {
    await appSettingsDataManager.setIsChatHistoryStored(value)
  }
  
  func setIsVoiceChangerEnabled(_ value: Bool) async {
    await appSettingsDataManager.setIsVoiceChangerEnabled(value)
  }
  
  func resetPasscode() async {
    await appSettingsDataManager.setAppPassword(nil)
  }
  
  func resetFakePasscode() async {
    await appSettingsDataManager.setFakeAppPassword(nil)
  }
  
  func getAppSettingsModel() async -> AppSettingsModel {
    await appSettingsDataManager.getAppSettingsModel()
  }
}

// MARK: - Private

private extension PasscodeSettingsScreenInteractor {}

// MARK: - Constants

private enum Constants {}
