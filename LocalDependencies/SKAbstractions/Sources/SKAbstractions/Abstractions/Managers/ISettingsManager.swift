//
//  ISettingsManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import Foundation

/// Протокол для управления настройками приложения.
public protocol ISettingsManager {
  /// Возвращает модель настроек приложения.
  /// - Returns: Модель настроек приложения.
  func getAppSettingsModel() async -> AppSettingsModel
  
  /// Проверяет, установлен ли код доступа в системе iOS.
  /// - Parameter errorMessage: Сообщение об ошибке, если код доступа не установлен.
  func passcodeNotSetInSystemIOSCheck(errorMessage: String) async
}
