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
  
  /// Устанавливает прочитанное или не прочитанное сообщение у контакта.
  /// - Parameters:
  ///   - value: Значение, указывающее, прочитано ли сообщение.
  ///   - toxAddress: Адрес контакта в Tox.
  func setIsNewMessagesAvailable(_ value: Bool, toxAddress: String) async
  
  /// Устанавливает поддельный пароль приложения.
  /// - Parameter value: Новый поддельный пароль для приложения.
  func setFakeAppPassword(_ value: String?) async
  
  /// Включает или отключает фальшивый доступ.
  /// - Parameter value: Значение, указывающее, следует ли включить фальшивый доступ.
  func setIsFakeAccessEnabled(_ value: Bool) async
  
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
