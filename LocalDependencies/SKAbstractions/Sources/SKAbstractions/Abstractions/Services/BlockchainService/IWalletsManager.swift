//
//  IWalletsManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 17.05.2024.
//

import Foundation

/// Протокол для менеджера кошельков.
public protocol IWalletsManager {
  /// Создает новый кошелек с 12-словной сид-фразой.
  /// - Returns: Созданный HD кошелек или nil в случае ошибки.
  func createWallet12Words() -> String?
  
  /// Создает новый кошелек с 24-словной сид-фразой.
  /// - Returns: Созданный HD кошелек или nil в случае ошибки.
  func createWallet24Words() -> String?
  
  /// Восстанавливает кошелек по сид-фразе.
  /// - Parameter mnemonic: Сид-фраза.
  /// - Returns: Восстановленный HD кошелек или nil в случае ошибки.
  func recoverMnemonic(_ mnemonic: String) -> String?
  
  /// Проверяет валидность мнемонической фразы.
  /// - Parameter input: Входная мнемоническая фраза.
  /// - Returns: Возвращает `true`, если фраза валидна, иначе `false`.
  func isValidMnemonic(_ input: String) -> Bool
  
  /// Проверяет валидность приватного ключа.
  /// - Parameters:
  ///   - input: Входной приватный ключ.
  /// - Returns: Возвращает `true`, если ключ валиден, иначе `false`.
  func isValidPrivateKey(_ input: String) -> Bool
  
  /// Получает мастер-ключ, публичный ключ и адрес кошелька из мнемонической фразы и кривой.
  /// - Parameters:
  ///   - mnemonic: Мнемоническая фраза.
  /// - Returns: Кортеж с адресом кошелька, публичным ключом и мастер-ключом в виде строк, или nil в случае ошибки.
  func getWalletDetails(mnemonic: String) -> (publicKey: String, privateKey: String)?
}
