//
//  SafeKeeperModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 17.05.2024.
//

import SwiftUI

/// Модель `SafeKeeperModel` представляет основную структуру данных для хранения информации о кошельках и настройках приложения.
/// Эта структура обеспечивает централизованное управление данными, связанными с пользовательскими кошельками и настройками приложения.
public struct SafeKeeperModel {
  
  // MARK: - Public properties
  
  /// Модель настроек приложения, содержащая различные пользовательские и системные настройки.
  public var appSettingsModel: AppSettingsModel
  
  /// Массив моделей кошельков, каждый из которых представляет отдельный кошелек пользователя.
  public var wallets: [WalletModel]
  
  // MARK: - Initializer
  
  /// Инициализирует новый экземпляр `SafeKeeperModel` с указанными настройками приложения и кошельками.
  ///
  /// - Parameters:
  ///   - appSettingsModel: Модель настроек приложения.
  ///   - wallets: Массив кошельков, которые будут управляться в приложении.
  public init(
    appSettingsModel: AppSettingsModel,
    wallets: [WalletModel]
  ) {
    self.appSettingsModel = appSettingsModel
    self.wallets = wallets
  }
}

// MARK: - IdentifiableAndCodable

extension SafeKeeperModel: IdentifiableAndCodable {}
