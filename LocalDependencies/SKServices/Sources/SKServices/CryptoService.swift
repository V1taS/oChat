//
//  CryptoService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 10.05.2024.
//

import Foundation
import SKAbstractions
import Ecies
import CryptoKit
import BigInt

// MARK: - CryptoService

public final class CryptoService: ICryptoService {
  public init() {}
  
  public func publicKey(from privateKey: String) -> String? {
    guard let privateKey = getPrivateKey(from: privateKey) else {
      return nil
    }
    let publicKey = ECPublicKey(privateKey: privateKey)
    let publicKeyPEM = publicKey.pem
    return publicKeyPEM
  }
  
  public func encrypt(_ message: String?, publicKey: String) -> String? {
    guard let message,
          let publicKey = try? ECPublicKey(pem: publicKey),
          let messageData = message.data(using: .utf8) else {
      return nil
    }
    
    let encryptedData = publicKey.encrypt(msg: messageData, cipher: .AES256)
    return encryptedData.base64EncodedString()
  }
  
  public func encrypt(_ data: Data?, publicKey: String) -> Data? {
    guard let data,
          let publicKey = try? ECPublicKey(pem: publicKey) else {
      return nil
    }
    
    return publicKey.encrypt(msg: data, cipher: .AES256)
  }
  
  public func decrypt(_ message: String?, privateKey: String) -> String? {
    guard let message,
          let privateKey = getPrivateKey(from: privateKey),
          let messageData = Data(base64Encoded: message) else {
      return nil
    }
    
    guard let decryptedData = try? privateKey.decrypt(msg: messageData, cipher: .AES256) else {
      return nil
    }
    return String(data: decryptedData, encoding: .utf8)
  }
  
  public func decrypt(_ data: Data?, privateKey: String) -> Data? {
    guard let data,
          let privateKey = getPrivateKey(from: privateKey) else {
      return nil
    }
    
    return try? privateKey.decrypt(msg: data, cipher: .AES256)
  }
  
  public func sha512(from input: String) -> String {
    let inputData = Data(input.utf8)
    return sha512(from: inputData)
  }
  
  public func sha512(from inputData: Data) -> String {
    let hashed = SHA512.hash(data: inputData)
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
  }
  
  public func sha256(from input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
  }
  
  public func sha256(from inputData: Data) -> String {
    let hashed = SHA256.hash(data: inputData)
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
  }
}

// MARK: - Private

private extension CryptoService {
  func getPrivateKey(from input: String) -> ECPrivateKey? {
    let hashed = SHA256.hash(data: Data(input.utf8))
    let hexHash = hashed.compactMap { String(format: "%02x", $0) }.joined()
    guard let privateKeyValue = BInt(hexHash, radix: 16) else {
      return nil
    }
    let domain = Domain.instance(curve: .EC384r1)
    
    guard let privateKey = try? ECPrivateKey(domain: domain, s: privateKeyValue) else {
      return nil
    }
    return privateKey
  }
}
