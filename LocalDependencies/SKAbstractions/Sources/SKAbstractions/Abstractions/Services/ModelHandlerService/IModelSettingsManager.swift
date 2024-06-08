//
//  IModelSettingsManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 20.05.2024.
//

import SwiftUI

// MARK: - IModelSettingsManager

/// Протокол для управления настройками модели кошелька.
public protocol IModelSettingsManager {
  
  /// Устанавливает, является ли кошелек основным.
  /// - Parameters:
  ///   - model: Модель кошелька `WalletModel`.
  ///   - value: Значение, указывающее, является ли кошелек основным (`true`) или нет (`false`).
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func setIsPrimaryWallet(_ model: WalletModel, _ value: Bool, completion: (() -> Void)?)
  
  /// Устанавливает имя кошелька.
  /// - Parameters:
  ///   - model: Модель кошелька `WalletModel`.
  ///   - name: Новое имя для кошелька.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func setNameWallet(_ model: WalletModel, _ name: String, completion: ((_ model: WalletModel?) -> Void)?)
  
  /// Удаляет кошелек.
  /// - Parameters:
  ///   - model: Модель кошелька `WalletModel`, которую нужно удалить.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func deleteWallet(_ model: WalletModel, completion: (() -> Void)?)
}
