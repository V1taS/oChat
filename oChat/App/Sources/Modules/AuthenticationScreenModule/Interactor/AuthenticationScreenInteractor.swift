//
//  AuthenticationScreenInteractor.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol AuthenticationScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol AuthenticationScreenInteractorInput {
  /// Запрос аутентификации через Face ID
  func authenticationWithFaceID() async -> Bool
  
  /// Получить старый код пароль, который был установлен пользователем
  func getOldAccessCode() async -> String?
  
  /// Получить фейковый код пароль, который был установлен пользователем
  func getFakeAccessCode() async -> String?
  
  /// Устанавливает пароль приложения.
  /// - Parameter value: Новый пароль для приложения.
  func setAppPassword(_ value: String?) async
  
  /// Устанавливает фейковый пароль приложения.
  /// - Parameter value: Новый фейковый пароль для приложения.
  func setFakeAppPassword(_ code: String?) async
  
  /// Установить доступ в приложение
  /// - Parameter accessType: Тип доступа
  func setAccessType(_ accessType: AppSettingsModel.AccessType) async
}

/// Интерактор
final class AuthenticationScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: AuthenticationScreenInteractorOutput?
  
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

// MARK: - AuthenticationScreenInteractorInput

extension AuthenticationScreenInteractor: AuthenticationScreenInteractorInput {
  func setAppPassword(_ code: String?) async {
    await appSettingsManager.setAppPassword(code)
  }
  
  func setFakeAppPassword(_ code: String?) async {
    await appSettingsManager.setFakeAppPassword(code)
  }
  
  func getOldAccessCode() async -> String? {
    await modelHandlerService.getAppSettingsModel().appPassword
  }
  
  func getFakeAccessCode() async -> String? {
    await modelHandlerService.getAppSettingsModel().fakeAppPassword
  }
  
  func authenticationWithFaceID() async -> Bool {
    await permissionService.requestFaceID()
  }
  
  func setAccessType(_ accessType: AppSettingsModel.AccessType) async {
    await appSettingsManager.setAccessType(accessType)
  }
}

// MARK: - Private

private extension AuthenticationScreenInteractor {}

// MARK: - Constants

private enum Constants {}
