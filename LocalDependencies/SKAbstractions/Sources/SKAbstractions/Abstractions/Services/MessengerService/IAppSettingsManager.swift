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
  /// Включает или отключает аутентификацию по Face ID.
  /// - Parameters:
  ///   - value: Значение, указывающее, следует ли включить аутентификацию по Face ID.
  ///   - completion: Опциональный блок завершения, вызываемый после сохранения изменений.
  func setIsEnabledFaceID(_ value: Bool, completion: (() -> Void)?)
  
  /// Устанавливает пароль приложения.
  /// - Parameters:
  ///   - value: Новый пароль для приложения.
  ///   - completion: Опциональный блок завершения, вызываемый после сохранения изменений.
  func setAppPassword(_ value: String?, completion: (() -> Void)?)
  
  /// Включает или отключает уведомления в приложении.
  /// - Parameters:
  ///   - value: Значение, указывающее, следует ли включить уведомления.
  ///   - completion: Опциональный блок завершения, вызываемый после сохранения изменений.
  func setIsEnabledNotifications(_ value: Bool, completion: (() -> Void)?)
}
