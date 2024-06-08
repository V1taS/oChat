//
//  MessagesService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 10.05.2024.
//

import Foundation
import SKAbstractions

public class MessagesService: IMessagesService {
  
  // MARK: - Private properties
  
  private let privateKey: String
  private let publicKey: String
  private var theirPublicKey: String?
  private let cryptoService: ICryptoService
  
  // MARK: - Init
  
  /// Инициализация сервиса с возможностью указания криптосервиса и приватного ключа.
  /// - Parameters:
  ///   - cryptoService: Сервис криптографии, используемый для шифрования и дешифрования.
  ///   - privateKey: Приватный ключ для расшифровки полученных сообщений.
  public init(
    cryptoService: ICryptoService = CryptoService(),
    privateKey: String
  ) {
    self.cryptoService = cryptoService
    self.privateKey = privateKey
    if let publicKey = cryptoService.publicKey(from: privateKey) {
      self.publicKey = publicKey
    } else {
      publicKey = ""
    }
  }
  
  public func getKeyExchangeType() -> MessengerKeyExchangeType {
    theirPublicKey != nil ? .encryption  : .handshakeStart
  }
  
  public func setTheirPublicKey(_ key: String?) {
    theirPublicKey = key
  }
  
  public func prepareMessage(_ message: String?) -> String? {
    let encryptedMessage = encrypt(message)
    let blockchainMessage = createBlockchainMessage(encryptedMessage)
    return blockchainMessage
  }
  
  public func handleReceiveMessages(_ message: String?) -> (theirPublicKey: String?, message: String?) {
    guard let message else {
      return (nil, nil)
    }
    let blockchainMessage = extractDataFromBlockchainMessage(message)
    let theirPublicKey = blockchainMessage.theirPublicKey
    let decryptMessage = decryptMessage(blockchainMessage.encryptedMessage)
    return (theirPublicKey, decryptMessage)
  }
}

// MARK: - Private

private extension MessagesService {
  func encrypt(_ message: String?) -> String? {
    guard let theirPublicKey, let message else {
      return nil
    }
    
    return cryptoService.encrypt(
      message,
      publicKey: theirPublicKey
    )
  }
  
  func decryptMessage(_ message: String?) -> String? {
    guard theirPublicKey != nil else {
      return nil
    }
    
    if let decrypted = cryptoService.decrypt(
      message,
      privateKey: privateKey
    ) {
      return decrypted
    }
    return nil
  }
  
  func createBlockchainMessage(_ encryptedMessage: String?) -> String? {
    guard let separator = Constants.separators.randomElement(),
          let msgTag = Constants.msgTags.randomElement() else {
      return nil
    }
    
    var result = "\(msgTag)\(separator)\(publicKey)"
    if let message = encryptedMessage {
      result += "\(separator)\(message)"
    }
    return result
  }
  
  func extractDataFromBlockchainMessage( _ message: String) -> (theirPublicKey: String?, encryptedMessage: String?) {
    /// Создаем паттерн для поиска по всем тегам и разделителям
    let tagsPattern = Constants.msgTags.joined(separator: "|")
    let separatorsPattern = Constants.separators.joined(separator: "|")
    
    /// Регулярное выражение для поиска
    let pattern = "(\(tagsPattern))(\(separatorsPattern))([a-zA-Z0-9]+)\\2(.*)"
    
    do {
      let regex = try NSRegularExpression(pattern: pattern, options: [])
      let nsrange = NSRange(message.startIndex..<message.endIndex, in: message)
      
      if let match = regex.firstMatch(in: message, options: [], range: nsrange) {
        /// Извлекаем publicKey
        let publicKeyRange = Range(match.range(at: 3), in: message)!
        let publicKey = String(message[publicKeyRange])
        
        /// Извлекаем encryptedMessage, если он есть
        let encryptedMessageRange = Range(match.range(at: 4), in: message)!
        let encryptedMessage = String(message[encryptedMessageRange])
        return (publicKey, encryptedMessage.isEmpty ? nil : encryptedMessage)
      }
    } catch {
      print("Ошибка регулярного выражения: \(error)")
    }
    
    return (nil, nil)
  }
}

// MARK: - Constants

private enum Constants {
  /// Список тегов для маркировки сообщений
  static let msgTags = [
    "scuCTncoeb",
    "T5PtYyhwjV",
    "EdlSxNF5S2",
    "CZfs4sThfT",
    "nmuclYjJL1",
    "8hGQkQmthQ",
    "y904xy3fg4",
    "r6GOUEYS90",
    "Sg5l0h8Iwj",
    "d21CUqtLyX",
    "3YotX0LZWF",
    "GKMit8l7BN",
    "zQhRQx4N82",
    "qGygOacvtN",
    "dqfmjVMpGv",
    "1vm5CyfQoL",
    "H8NzGtBr4m",
    "wRy8Gem1DD",
    "X9gRZ03EcZ",
    "Wf43rMG3Nb"
  ]
  
  /// Список разделителей для структурирования сообщений
  static let separators = [
    "lGnuiVmjkh",
    "qgfTVclVbj",
    "Ge0qDI4AAL",
    "H7YN0W5kku",
    "sJhWAmcTMh",
    "gOxgqUrLJ0",
    "rYPvIiEWZT",
    "twXlCCTffP",
    "rVlCpRcaXZ",
    "Umn8P7rQdc",
    "Ss7ZVKHeAU",
    "hiJTyVcCxv",
    "RZhi7Q4fws",
    "seIKpQnLJ0",
    "QMj54gS4j9"
  ]
}
