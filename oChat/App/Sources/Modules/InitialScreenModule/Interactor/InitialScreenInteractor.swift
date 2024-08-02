//
//  InitialScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol InitialScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol InitialScreenInteractorInput {
  /// Установить доступ в приложение
  /// - Parameter accessType: Тип доступа
  func setAccessType(_ accessType: AppSettingsModel.AccessType) async
}

/// Интерактор
final class InitialScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: InitialScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let appSettingsManager: IAppSettingsManager
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    appSettingsManager = services.messengerService.appSettingsManager
  }
}

// MARK: - InitialScreenInteractorInput

extension InitialScreenInteractor: InitialScreenInteractorInput {
  func setAccessType(_ accessType: AppSettingsModel.AccessType) async {
    await appSettingsManager.setAccessType(accessType)
  }
}

// MARK: - Private

private extension InitialScreenInteractor {}

// MARK: - Constants

private enum Constants {}
