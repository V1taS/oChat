//
//  ITorServer.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.06.2024.
//

import Foundation

/// Протокол для сервера, работающего с сетью Tor.
/// - Определяет обработчик состояния сервера.
public protocol ITorServer {
  /// Обработчик, который вызывается при изменении состояния сервера.
  var stateAction: ((TorServerState) -> Void)? { get set }
  
  /// Запуск Сервера
  func start()
}
