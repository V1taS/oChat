//
//  TorSessionState.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.06.2024.
//

import Foundation

/// Перечисление, описывающее состояния подключения к Tor.
public enum TorSessionState {
  /// Состояние не определено или подключение не инициализировано.
  case none
  /// Подключение начато, идет процесс инициализации.
  case started
  /// Вызывается для уведомления о прогрессе подключения к Tor.
  /// - Parameter progress: Процент завершения процесса подключения.
  case connectingProgress(_ progress: Int)
  /// Подключение успешно установлено.
  case connected
  /// Подключение остановлено.
  case stopped
  /// Подключение обновляется.
  case refreshing
  /// Состояние `circuitsUpdated` активируется при изменении статуса одной или нескольких цепочек Tor.
  case circuitsUpdated(String)
}
