//
//  IAccessAndSecurityManagementService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 31.05.2024.
//

import Foundation

/// Протокол для управления безопасностью и доступом в приложении.
public protocol IAccessAndSecurityManagementService {
  /// Сервис для управления сессиями пользователя.
  var sessionService: ISessionService { get }
  
  /// Возвращает сервис запроса доступов.
  /// - Returns: Сервис управления доступами.
  var permissionService: IPermissionService { get }
  
  /// Возвращает сервис по работе с стеганографией в изображениях.
  /// - Returns: Сервис стеганографии.
  var steganographyService: ISteganographyService { get }
  
  /// Возвращает сервис шифрования с использованием ECIES.
  /// - Returns: Сервис шифрования.
  var cryptoService: ICryptoService { get }
}
