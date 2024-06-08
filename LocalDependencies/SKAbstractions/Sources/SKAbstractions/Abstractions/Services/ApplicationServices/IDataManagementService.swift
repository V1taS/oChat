//
//  IDataManagementService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 31.05.2024.
//

import Foundation

/// Протокол для управления сервисами, связанными с данными в приложении.
public protocol IDataManagementService {
  /// Возвращает сервис управления данными.
  /// - Returns: Сервис управления данными.
  var dataManagerService: IDataManagerService { get }
  
  /// Возвращает сервис для работы с маппингом данных.
  /// - Returns: Сервис для маппинга данных.
  var dataMappingService: IDataMappingService { get }
  
  /// Возвращает сервис управления безопасным хранением данных.
  /// - Parameters:
  ///   - serviceName: Ключ для определения типа сервиса безопасного хранения данных.
  /// - Returns: Сервис безопасного хранения данных.
  func getSecureDataManagerService(_ serviceName: SecureDataManagerServiceKey) -> ISecureDataManagerService
}
