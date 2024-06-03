//
//  IUserInterfaceAndExperienceService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 31.05.2024.
//

import Foundation

/// Протокол для управления интерфейсом пользователя и опытом использования приложения.
public protocol IUserInterfaceAndExperienceService {
  /// Возвращает сервис для работы с пользовательским интерфейсом в приложении.
  /// - Returns: Сервис пользовательского интерфейса.
  var uiService: IUIService { get }
  
  /// Возвращает сервис для работы с системными службами.
  /// - Returns: Сервис системных служб.
  var systemService: ISystemService { get }
  
  /// Возвращает сервис уведомлений.
  /// - Returns: Сервис уведомлений.
  var notificationService: INotificationService { get }
}
