//
//  WalletsManager.swift
//  SKServices
//
//  Created by Vitalii Sosin on 12.05.2024.
//

import Foundation
import WalletCore
import SKFoundation
import SKAbstractions

/// Финальный класс для управления кошельками.
public final class WalletsManager: IWalletsManager {
  /// Инициализатор
  public init() {}
  
  /// Создает новый кошелек с 12-словной сид-фразой.
  /// - Returns: Созданный HD кошелек или nil в случае ошибки.
  public func createWallet12Words() -> String? {
    return HDWallet(strength: 128, passphrase: "")?.mnemonic
  }
  
  /// Создает новый кошелек с 24-словной сид-фразой.
  /// - Returns: Созданный HD кошелек или nil в случае ошибки.
  public func createWallet24Words() -> String? {
    return HDWallet(strength: 256, passphrase: "")?.mnemonic
  }
  
  /// Восстанавливает кошелек по сид-фразе.
  /// - Parameter mnemonic: Сид-фраза.
  /// - Returns: Восстановленный HD кошелек или nil в случае ошибки.
  public func recoverMnemonic(_ mnemonic: String) -> String? {
    return HDWallet(mnemonic: mnemonic, passphrase: "")?.mnemonic
  }
  
  /// Проверяет валидность мнемонической фразы.
  /// - Parameter input: Входная мнемоническая фраза.
  /// - Returns: Возвращает `true`, если фраза валидна, иначе `false`.
  public func isValidMnemonic(_ input: String) -> Bool {
    let trimmedInput = input.singleSpaced
    return Mnemonic.isValid(mnemonic: trimmedInput)
  }
  
  /// Проверяет валидность приватного ключа.
  /// - Parameters:
  ///   - input: Входной приватный ключ.
  /// - Returns: Возвращает `true`, если ключ валиден, иначе `false`.
  public func isValidPrivateKey(_ input: String) -> Bool {
    let trimmedInput = input.singleSpaced
    let data = Data(hexString: trimmedInput) ?? Data()
    return PrivateKey.isValid(data: data, curve: .secp256k1)
  }
  
  
  /// Получает мастер-ключ, публичный ключ и адрес кошелька из мнемонической фразы.
  /// - Parameters:
  ///   - mnemonic: Мнемоническая фраза.
  /// - Returns: Кортеж с адресом кошелька, публичным ключом и мастер-ключом в виде строк, или nil в случае ошибки.
  public func getWalletDetails(mnemonic: String) -> (publicKey: String, privateKey: String)? {
    guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") else {
      return nil
    }
    let masterPrivateKey = wallet.getMasterKey(curve: .secp256k1)
    let publicKey = masterPrivateKey.getPublicKeySecp256k1(compressed: true)
    
    return (publicKey: publicKey.data.hexString, privateKey: masterPrivateKey.data.hexString)
  }
}
