//
//  ISystemService.swift
//
//
//  Created by Vitalii Sosin on 26.02.2024.
//

import Foundation

/// Сервис для работы с системными службами
public protocol ISystemService {
  /// Открывает системные настройки.
  /// - Parameter Error: Ошибка `SystemServiceError`, если не удается открыть настройки.
  func openSettings(completion: @escaping (Result<Void, SystemServiceError>) -> Void)
  
  /// Открывает системные настройки.
  func openSettings()
  
  /// Копирует текст в буфер обмена.
  /// - Parameters:
  ///   - text: Текст для копирования.
  ///   - completion: Замыкание, вызываемое с результатом операции.
  func copyToClipboard(text: String, completion: @escaping (Result<Void, SystemServiceError>) -> Void)
  
  /// Копирует текст в буфер обмена.
  /// - Parameters:
  ///   - text: Текст для копирования.
  func copyToClipboard(text: String)
  
  /// Открывает URL в Safari внутри приложения.
  /// - Parameters:
  ///   - urlString: Строка URL для открытия.
  ///   - completion: Замыкание, вызываемое с результатом операции.
  func openURLInSafari(urlString: String, completion: @escaping (Result<Void, SystemServiceError>) -> Void)
  
  /// Открывает URL в Safari внутри приложения.
  /// - Parameters:
  ///   - urlString: Строка URL для открытия.
  func openURLInSafari(urlString: String)
  
  /// Возвращает текущий язык приложения.
  /// Метод анализирует системные настройки и возвращает один из поддерживаемых языков,
  /// указанных в перечислении `AppLanguageType`.
  /// - Returns: Текущий язык приложения как значение перечисления `AppLanguageType`.
  func getCurrentLanguage() -> AppLanguageType
  
  /// Возвращает модель устройства.
  /// - Returns: Строка, представляющая модель устройства, например, "iPhone".
  func getDeviceModel() -> String
  
  /// Возвращает название операционной системы.
  /// - Returns: Строка с названием системы, например, "iOS".
  func getSystemName() -> String
  
  /// Возвращает версию операционной системы.
  /// - Returns: Строка с версией системы, например, "13.3".
  func getSystemVersion() -> String
  
  /// Возвращает уникальный идентификатор устройства.
  /// - Returns: Строка, содержащая UUID устройства или "Unknown", если идентификатор не доступен.
  func getDeviceIdentifier() -> String
  
  /// Возвращает текущую версию приложения.
  /// - Returns: Строка с версией приложения, например, "1.0".
  func getAppVersion() -> String
  
  /// Возвращает номер сборки приложения.
  /// - Returns: Строка с номером сборки, например, "101".
  func getAppBuildNumber() -> String
  
  /// Проверяет, установлен ли пароль на устройстве.
  /// - Parameter completion: Замыкание, вызываемое с результатом проверки.
  ///  Если пароль установлен, возвращает `.success`.
  ///  В противном случае возвращает `.failure` с ошибкой `SystemServiceError.passcodeNotSet`.
  func checkIfPasscodeIsSet(completion: ((Result<Void, SystemServiceError>) -> Void)?)
}
