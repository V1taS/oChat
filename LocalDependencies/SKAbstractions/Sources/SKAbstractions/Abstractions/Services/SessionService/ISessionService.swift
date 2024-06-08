//
//  ISessionService.swift
//
//
//  Created by Vitalii Sosin on 26.02.2024.
//

import Foundation

/// Сервис для управления сессиями в приложении.
public protocol ISessionService {
  /// Вызывается при завершении сессии
  var sessionDidExpireAction: (() -> Void)? { get set }
  
  /// Начинает сессию пользователя.
  func startSession()
  
  /// Обновляет время последней активности пользователя.
  func updateLastActivityTime()
  
  /// Завершает сессию пользователя.
  func sessionDidExpire()
  
  /// Проверяет, активна ли сессия.
  /// - Returns: Булево значение, указывающее, активна ли сессия.
  func isSessionActive() -> Bool
}
