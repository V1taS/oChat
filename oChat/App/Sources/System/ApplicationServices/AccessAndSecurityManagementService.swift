//
//  AccessAndSecurityManagementService.swift
//  oChat
//
//  Created by Vitalii Sosin on 31.05.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKAbstractions
import SKServices

// MARK: - AccessAndSecurityManagementService

final class AccessAndSecurityManagementService: IAccessAndSecurityManagementService {

  // MARK: - Properties
  
  /// Сервис для управления сессиями в приложении.
  var sessionService: ISessionService {
    appSessionService
  }
  
  /// Возвращает сервис запроса доступов.
  var permissionService: IPermissionService {
    PermissionService()
  }
  
  /// Возвращает сервис по работе с стеганографией в изображениях.
  var steganographyService: ISteganographyService {
    SteganographyService()
  }
  
  /// Возвращает сервис шифрования с использованием ECIES.
  var cryptoService: ICryptoService {
    CryptoService()
  }
}

// MARK: - Impl

private let appSessionService = SessionService(
  secureStore: SecureDataManagerService(.session)
)
