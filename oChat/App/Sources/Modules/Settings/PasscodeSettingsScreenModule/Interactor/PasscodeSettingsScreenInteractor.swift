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
  /// Запрос доступа к Face ID для аутентификации
  /// - Parameter granted: Булево значение, указывающее, было ли предоставлено разрешение
  func requestFaceID(completion: @escaping (_ granted: Bool) -> Void)
  /// Сохранить состояние FaceID
  func saveFaceIDState(_ value: Bool)
  /// Получить состояние FaceID
  func getFaceIDState(completion: ((_ value: Bool) -> Void)?)
  /// Возвращает статус экрана блокировки.
  func getIsLockScreen(completion: ((_ value: Bool) -> Void)?)
  /// Сбрасывает текущий код доступа до значения по умолчанию.
  func resetPasscode()
  /// Возвращает начальные значения для состояния FaceID и показа изменения кода доступа.
  /// - Parameter completion: Замыкание, которое принимает два значения:
  ///   - `stateFaceID`: Булево значение, указывающее, включен ли FaceID.
  ///   - `isShowChangeAccessCode`: Булево значение, указывающее, показывать ли изменение кода доступа.
  func getInitialValue(completion: ((_ stateFaceID: Bool, _ isShowChangeAccessCode: Bool) -> Void)?)
}

/// Интерактор
final class PasscodeSettingsScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: PasscodeSettingsScreenInteractorOutput?
  
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

// MARK: - PasscodeSettingsScreenInteractorInput

extension PasscodeSettingsScreenInteractor: PasscodeSettingsScreenInteractorInput {
  func getInitialValue(completion: ((_ stateFaceID: Bool, _ isShowChangeAccessCode: Bool) -> Void)?) {
    modelHandlerService.getAppSettingsModel { appSettingsModel in
      completion?(appSettingsModel.isFaceIDEnabled, appSettingsModel.appPassword != nil)
    }
  }
  
  func resetPasscode() {
    appSettingsManager.setAppPassword(nil, completion: { [weak self] in
      self?.appSettingsManager.setIsEnabledFaceID(false, completion: nil)
    })
  }
  
  func getIsLockScreen(completion: ((_ value: Bool) -> Void)?) {
    modelHandlerService.getAppSettingsModel { appSettingsModel in
      completion?(appSettingsModel.appPassword != nil)
    }
  }
  
  func saveFaceIDState(_ value: Bool) {
    appSettingsManager.setIsEnabledFaceID(value, completion: nil)
  }
  
  func getFaceIDState(completion: ((_ value: Bool) -> Void)?) {
    modelHandlerService.getAppSettingsModel { appSettingsModel in
      completion?(appSettingsModel.isFaceIDEnabled)
    }
  }
  
  func requestFaceID(completion: @escaping (Bool) -> Void) {
    permissionService.requestFaceID(completion: completion)
  }
}

// MARK: - Private

private extension PasscodeSettingsScreenInteractor {}

// MARK: - Constants

private enum Constants {}
