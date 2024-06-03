//
//  TorServerState.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.06.2024.
//

import Foundation

/// Перечисление, описывающее возможные состояния сервера.
public enum TorServerState {
  /// Сервер запущен и слушает на указанном порту.
  case serverIsRunning(onPort: UInt16)
  /// Произошла ошибка при запуске сервера.
  case errorStartingServer(error: String)
  /// Сервер принял новое соединение.
  case didAcceptNewSocket
  /// Сервер прочитал данные.
  case didReadData(_ data: Data)
  /// Сервер получил сообщение.
  case didReceiveMessage(_ message: String)
  /// Сервер отправил ответ.
  case didSentResponse
  /// Соединение было разорвано.
  case socketDidDisconnect
}
