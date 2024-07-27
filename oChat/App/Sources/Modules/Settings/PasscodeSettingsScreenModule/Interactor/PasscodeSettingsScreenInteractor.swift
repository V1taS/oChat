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
  func requestFaceID() async -> Bool
  /// Сохранить состояние FaceID
  func saveFaceIDState(_ value: Bool) async
  /// Получить состояние FaceID
  func getFaceIDState() async -> Bool
  /// Возвращает статус экрана блокировки.
  func getIsLockScreen() async -> Bool
  /// Сбрасывает текущий код доступа до значения по умолчанию.
  func resetPasscode() async
  /// Возвращает начальные значения для состояния FaceID и показа изменения кода доступа.
  /// - Parameters:
  ///  - `stateFaceID`: Булево значение, указывающее, включен ли FaceID.
  ///  - `isShowChangeAccessCode`: Булево значение, указывающее, показывать ли изменение кода доступа.
  func getInitialValue() async -> (stateFaceID: Bool, isShowChangeAccessCode: Bool)
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
  func getInitialValue() async -> (stateFaceID: Bool, isShowChangeAccessCode: Bool) {
    let appSettingsModel = await modelHandlerService.getAppSettingsModel()
    return (appSettingsModel.isFaceIDEnabled, appSettingsModel.appPassword != nil)
  }
  
  func resetPasscode() async {
    await appSettingsManager.setAppPassword(nil)
    await appSettingsManager.setIsEnabledFaceID(false)
  }
  
  func getIsLockScreen() async -> Bool {
    await modelHandlerService.getAppSettingsModel().appPassword != nil
  }
  
  func saveFaceIDState(_ value: Bool) async {
    await appSettingsManager.setIsEnabledFaceID(value)
  }
  
  func getFaceIDState() async -> Bool {
    await modelHandlerService.getAppSettingsModel().isFaceIDEnabled
  }
  
  func requestFaceID() async -> Bool {
    await permissionService.requestFaceID()
  }
}

// MARK: - Private

private extension PasscodeSettingsScreenInteractor {}

// MARK: - Constants

private enum Constants {}
