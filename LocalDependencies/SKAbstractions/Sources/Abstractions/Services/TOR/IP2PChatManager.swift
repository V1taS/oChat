//
//  IP2PChatManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.06.2024.
//

import Foundation

/// Протокол управления чатом P2P через Tor.
public protocol IP2PChatManager {
  /// Действие, вызываемое при изменении состояния сервера.
  var serverStateAction: ((TorServerState) -> Void)? { get set }
  
  /// Действие, вызываемое при изменении состояния сессии.
  var sessionStateAction: ((_ state: TorSessionState) -> Void)? { get set }
  
  /// Действие, вызываемое при ошибке в сервисе.
  var stateErrorServiceAction: ((_ state: Result<Void, TorServiceError>) -> Void)? { get set }
  
  /// Получает адрес onion-сервиса.
  ///
  /// - Returns: Адрес сервиса или ошибка.
  func getOnionAddress() -> Result<String, TorServiceError>
  
  /// Получает приватный ключ для onion-сервиса.
  ///
  /// - Returns: Приватный ключ или ошибка.
  func getPrivateKey() -> Result<String, TorServiceError>
  
  /// Запускает Tor-сервис.
  ///
  /// - Parameter completion: Блок, вызываемый по завершении.
  func start(completion: ((Result<Void, TorServiceError>) -> Void)?)
  
  /// Останавливает Tor-сервис.
  ///
  /// - Returns: Результат выполнения операции.
  func stop() -> Result<Void, TorServiceError>
  
  /// Отправляет сообщение.
  ///
  /// - Parameters:
  ///   - message: Сообщение для отправки.
  ///   - peerAddress: Адрес получателя.
  ///   - completion: Блок, вызываемый по завершении.
  func sendMessage(
    _ message: String,
    peerAddress: String,
    completion: ((Result<Void, Error>) -> Void)?
  )
}
