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
  
  /// Получает адрес onion-сервиса.
  ///
  /// - Returns: Адрес сервиса или ошибка.
  func getOnionAddress(completion: ((Result<String, TorServiceError>) -> Void)?)
  
  /// Получает приватный ключ для onion-сервиса.
  ///
  /// - Returns: Приватный ключ или ошибка.
  func getPrivateKey(completion: ((Result<String, TorServiceError>) -> Void)?)
  
  /// Запускает Tor-сервис.
  ///
  /// - Parameter completion: Блок, вызываемый по завершении.
  func start(completion: ((Result<Void, TorServiceError>) -> Void)?)
  
  /// Останавливает Tor-сервис.
  ///
  /// - Returns: Результат выполнения операции.
  func stop(completion: ((Result<Void, TorServiceError>) -> Void)?)
  
  /// Проверяет доступность сервера по указанному адресу.
  /// - Parameters:
  ///   - onionAddress: Адрес сервера в сети Onion.
  ///   - completion: Блок завершения, который возвращает `Bool` указывающий доступность сервера.
  func checkServerAvailability(
    onionAddress: String,
    completion: @escaping (_ isAvailable: Bool) -> Void
  )
  
  /// Отправляет сообщение на сервер.
  /// - Parameters:
  ///   - onionAddress: Адрес сервера в сети Onion.
  ///   - messengerRequest: Данные запроса в виде `MessengerNetworkRequest`, содержащие информацию для отправки.
  ///   - completion: Блок завершения, который возвращает `Result<Void, Error>` указывающий успешность операции.
  func sendMessage(
    onionAddress: String,
    messengerRequest: MessengerNetworkRequestModel?,
    completion: @escaping (Result<Void, Error>) -> Void
  )
  
  /// Инициирует переписку по указанному адресу.
  /// - Parameters:
  ///   - onionAddress: Адрес сервера в сети Onion.
  ///   - messengerRequest: Данные запроса в виде `MessengerNetworkRequest`, содержащие информацию для начала переписки.
  ///   - completion: Блок завершения, который возвращает `Result<Void, Error>` указывающий успешность операции.
  func initiateChat(
    onionAddress: String,
    messengerRequest: MessengerNetworkRequestModel?,
    completion: @escaping (Result<Void, Error>) -> Void
  )
}
