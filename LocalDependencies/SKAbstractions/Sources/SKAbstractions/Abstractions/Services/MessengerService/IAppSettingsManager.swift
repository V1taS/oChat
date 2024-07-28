//
//  IAppSettingsManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 18.05.2024.
//

import Foundation

/// Протокол `IAppSettingsManager` предназначен для управления настройками приложения.
/// Определяет функции для изменения настроек безопасности, валюты и уведомлений.
public protocol IAppSettingsManager {  
  /// Устанавливает пароль приложения.
  /// - Parameter value: Новый пароль для приложения.
  func setAppPassword(_ value: String?) async
  
  /// Включает или отключает уведомления в приложении.
  /// - Parameter value: Значение, указывающее, следует ли включить уведомления.
  func setIsEnabledNotifications(_ value: Bool) async
  
  /// Устанавливает прочитанное или не прочитанное сообщение у контакта
  /// - Parameters:
  ///   - value: Значение, указывающее, прочитано ли сообщение.
  ///   - toxAddress: Адрес контакта в Tox.
  func setIsNewMessagesAvailable(_ value: Bool, toxAddress: String) async
}
