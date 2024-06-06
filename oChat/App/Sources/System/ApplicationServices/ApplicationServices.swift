//
//  ApplicationServices.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKAbstractions
import SKServices
import SKUIKit

// MARK: - ApplicationServices

final class ApplicationServices: IApplicationServices {
  
  // MARK: - Properties
  
  /// Возвращает сервис для управления сервисами, связанными с данными в приложении
  var dataManagementService: IDataManagementService {
    DataManagementService()
  }
  
  /// Возвращает сервис для управления безопасностью и доступом в приложении.
  var accessAndSecurityManagementService: IAccessAndSecurityManagementService {
    AccessAndSecurityManagementService()
  }
  
  /// Возвращает сервис для управления интерфейсом пользователя и опытом использования приложения.
  var userInterfaceAndExperienceService: IUserInterfaceAndExperienceService {
    UserInterfaceAndExperienceService()
  }
  
  /// Возвращает сервис для работы с аналитикой.
  var analyticsService: IAnalyticsService {
    AnalyticsService()
  }
  
  /// Возвращает сервис CloudKit для получения конфигурационных данных.
  var cloudKitService: ICloudKitService {
    CloudKitService()
  }
  
  /// Возвращает сервис  для управления сервисами, связанными с мессенджером
  var messengerService: IMessengerService {
    MessengerService()
  }
  
  /// Определяет интерфейс для взаимодействия с блокчейн-сервисами.
  var blockchainService: IBlockchainService {
    BlockchainService()
  }
  
  /// Управляет чатом P2P через Tor.
  var p2pChatManager: IP2PChatManager {
    P2PChatManager.shared
  }
}
