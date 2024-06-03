//
//  AuthenticationScreenInteractor.swift
//  oChat
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
  func authenticationWithFaceID(completion: @escaping (_ granted: Bool) -> Void)
  /// Получить старый код пароль, который был установлен пользователем
  func getOldAccessCode(completion: ((_ code: String?) -> Void)?)
  /// Указывает, включена ли разблокировка по FaceID.
  func getIsFaceIDEnabled(completion: ((Bool) -> Void)?)
  /// Устанавливает код доступа для всего приложения
  /// - Parameters:
  ///   - code: Код доступа, который необходимо установить.
  ///   - completion: Замыкающее выражение, которое будет выполнено после установки кода доступа. Может быть `nil`.
  func setAccessCode(_ code: String, completion: (() -> Void)?)
}

/// Интерактор
final class AuthenticationScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: AuthenticationScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let permissionService: IPermissionService
  private let modelHandlerService: IModelHandlerService
  private let appSettingsManager: IAppSettingsManager
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    permissionService = services.accessAndSecurityManagementService.permissionService
    modelHandlerService = services.dataManagementService.modelHandlerService
    appSettingsManager = services.dataManagementService.appSettingsManager
  }
}

// MARK: - AuthenticationScreenInteractorInput

extension AuthenticationScreenInteractor: AuthenticationScreenInteractorInput {
  func setAccessCode(_ code: String, completion: (() -> Void)?) {
    appSettingsManager.setAppPassword(code, completion: completion)
  }
  
  func getIsFaceIDEnabled(completion: ((Bool) -> Void)?) {
    modelHandlerService.getAppSettingsModel { appSettingsModel in
      completion?(appSettingsModel.isFaceIDEnabled)
    }
  }
  
  func getOldAccessCode(completion: ((String?) -> Void)?) {
    modelHandlerService.getAppSettingsModel { appSettingsModel in
      completion?(appSettingsModel.appPassword)
    }
  }
  
  func authenticationWithFaceID(completion: @escaping (_ granted: Bool) -> Void) {
    permissionService.requestFaceID(completion: completion)
  }
}

// MARK: - Private

private extension AuthenticationScreenInteractor {}

// MARK: - Constants

private enum Constants {}
