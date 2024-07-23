//
//  NotificationsSettingsScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol NotificationsSettingsScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol NotificationsSettingsScreenInteractorInput {
  /// Запрос доступа к Уведомлениям
  /// - Parameter granted: Булево значение, указывающее, было ли предоставлено разрешение
  func requestNotification(completion: @escaping (_ granted: Bool) -> Void)
  
  /// Метод для проверки, включены ли уведомления
  /// - Parameter enabled: Булево значение, указывающее, было ли включено уведомление
  func isNotificationsEnabled(completion: @escaping (_ enabled: Bool) -> Void)
}

/// Интерактор
final class NotificationsSettingsScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: NotificationsSettingsScreenInteractorOutput?
  
  // MARK: - Private properties
  
  let permissionService: IPermissionService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    permissionService = services.accessAndSecurityManagementService.permissionService
  }
}

// MARK: - NotificationsSettingsScreenInteractorInput

extension NotificationsSettingsScreenInteractor: NotificationsSettingsScreenInteractorInput {
  func requestNotification(completion: @escaping (Bool) -> Void) {
    Task {
      let granted = await permissionService.requestNotification()
      completion(granted)
    }
  }
  
  func isNotificationsEnabled(completion: @escaping (Bool) -> Void) {
    Task {
      let isNotificationsEnabled = await permissionService.isNotificationsEnabled()
      completion(isNotificationsEnabled)
    }
  }
}

// MARK: - Private

private extension NotificationsSettingsScreenInteractor {}

// MARK: - Constants

private enum Constants {}
