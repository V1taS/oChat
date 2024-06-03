//
//  DataManagementService.swift
//  oChat
//
//  Created by Vitalii Sosin on 31.05.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKAbstractions
import SKServices

// MARK: - DataManagementService

final class DataManagementService: IDataManagementService {
  
  // MARK: - Properties
  
  /// Возвращает сервис управления данными.
  var dataManagerService: IDataManagerService {
    DataManagerService()
  }
  
  /// Возвращает сервис для работы с маппингом данных.
  var dataMappingService: IDataMappingService {
    DataMappingService()
  }
  
  /// Предназначен для обработки и управления моделями данных в приложении.
  var modelHandlerService: IModelHandlerService {
    modelHandlerServiceImpl
  }
  
  /// Предназначен для управления настройками приложения.
  var appSettingsManager: IAppSettingsManager {
    modelHandlerServiceImpl
  }
  
  /// Управление настройками модели кошелька.
  var modelSettingsManager: IModelSettingsManager {
    modelHandlerServiceImpl
  }
  
  // MARK: - Funcs
  
  /// Возвращает сервис управления безопасным хранением данных.
  func getSecureDataManagerService(_ serviceName: SecureDataManagerServiceKey) -> ISecureDataManagerService {
    SecureDataManagerService(serviceName)
  }
}

// MARK: - Impl

private let modelHandlerServiceImpl = ModelHandlerService()
