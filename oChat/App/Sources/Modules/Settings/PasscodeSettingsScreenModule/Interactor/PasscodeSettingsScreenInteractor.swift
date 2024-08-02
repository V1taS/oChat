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
  /// Сбрасывает текущий код доступа до значения по умолчанию.
  func resetPasscode() async
  
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
}

/// Интерактор
final class PasscodeSettingsScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: PasscodeSettingsScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let permissionService: IPermissionService
  private let modelHandlerService: IMessengerModelHandlerService
  private let appSettingsManager: IAppSettingsManager
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    permissionService = services.accessAndSecurityManagementService.permissionService
    modelHandlerService = services.messengerService.modelHandlerService
    appSettingsManager = services.messengerService.appSettingsManager
  }
}

// MARK: - PasscodeSettingsScreenInteractorInput

extension PasscodeSettingsScreenInteractor: PasscodeSettingsScreenInteractorInput {
  func setFakeAppPassword(_ value: String?) async {
    await appSettingsManager.setFakeAppPassword(value)
  }
  
  func setAccessType(_ accessType: AppSettingsModel.AccessType) async {
    await appSettingsManager.setAccessType(accessType)
  }
  
  func setIsPremiumEnabled(_ value: Bool) async {
    await appSettingsManager.setIsPremiumEnabled(value)
  }
  
  func setIsTypingIndicatorEnabled(_ value: Bool) async {
    await appSettingsManager.setIsTypingIndicatorEnabled(value)
  }
  
  func setCanSaveMedia(_ value: Bool) async {
    await appSettingsManager.setCanSaveMedia(value)
  }
  
  func setIsChatHistoryStored(_ value: Bool) async {
    await appSettingsManager.setIsChatHistoryStored(value)
  }
  
  func setIsVoiceChangerEnabled(_ value: Bool) async {
    await appSettingsManager.setIsVoiceChangerEnabled(value)
  }
  
  func resetPasscode() async {
    await appSettingsManager.setAppPassword(nil)
  }
  
  func getAppSettingsModel() async -> AppSettingsModel {
    await modelHandlerService.getAppSettingsModel()
  }
}

// MARK: - Private

private extension PasscodeSettingsScreenInteractor {}

// MARK: - Constants

private enum Constants {}
