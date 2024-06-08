//
//  ITorService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.06.2024.
//

import Foundation

/// Протокол, описывающий основные методы и свойства для работы с Tor сервисом
public protocol ITorService {
  /// Действие, выполняемое при изменении состояния сессии Tor
  var stateAction: ((_ state: TorSessionState) -> Void)? { get set }
  
  /// Получение сессии URLSession, сконфигурированной для работы через Tor
  func getSession() -> URLSession
  
  /// Получение адреса onion-сервиса
  func getOnionAddress() -> Result<String, TorServiceError>
  
  /// Получение приватного ключа для onion-сервиса
  func getPrivateKey() -> Result<String, TorServiceError>
  
  /// Запуск Tor-сервиса
  func start(completion: ((Result<Void, TorServiceError>) -> Void)?)
  
  /// Остановка Tor-сервиса
  func stop() -> Result<Void, TorServiceError>
}
