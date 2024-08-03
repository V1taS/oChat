//
//  IToxManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import Foundation

/// Протокол для управления Tox-сервисом.
public protocol IToxManager {
  /// Запускает периодическую проверку статуса друзей.
  /// - Parameter completion: Завершающий блок, который вызывается после завершения проверки.
  func startPeriodicFriendStatusCheck(completion: (() -> Void)?) async
  
  /// Запускает Tox-сервис.
  func startToxService() async
  
  /// Возвращает Tox-адрес.
  /// - Returns: Tox-адрес или nil, если не удалось получить.
  func getToxAddress() async -> String?
  
  /// Возвращает публичный ключ Tox.
  /// - Returns: Публичный ключ Tox или nil, если не удалось получить.
  func getToxPublicKey() async -> String?
  
  /// Возвращает публичный ключ Tox из адреса.
  /// - Parameter address: Адрес Tox.
  /// - Returns: Публичный ключ Tox или nil, если не удалось получить.
  func getToxPublicKey(from address: String) -> String?
  
  /// Подтверждает запрос в друзья.
  /// - Parameter publicToxKey: Публичный ключ Tox друга.
  /// - Returns: Идентификатор друга или nil, если не удалось подтвердить запрос.
  func confirmFriendRequest(with publicToxKey: String) async -> String?
  
  /// Устанавливает статус "в сети" для текущего пользователя.
  /// - Parameter isOnline: Статус "в сети".
  func setSelfStatus(isOnline: Bool) async
  
  /// Устанавливает статус "печатает" для пользователя.
  /// - Parameters:
  ///   - isTyping: Статус "печатает".
  ///   - toxPublicKey: Публичный ключ Tox пользователя.
  /// - Returns: Результат выполнения операции.
  func setUserIsTyping(_ isTyping: Bool, to toxPublicKey: String) async -> Result<Void, Error>
}
