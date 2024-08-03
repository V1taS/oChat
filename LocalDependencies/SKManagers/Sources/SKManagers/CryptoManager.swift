//
//  CryptoManager.swift
//  SKManagers
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle

public final class CryptoManager: ICryptoManager {
  
  // MARK: - Private properties
  
  private let cryptoService: ICryptoService
  private let systemService: ISystemService
  
  // MARK: - Init
  
  public init(
    cryptoService: ICryptoService,
    systemService: ISystemService
  ) {
    self.cryptoService = cryptoService
    self.systemService = systemService
  }
  
  // MARK: - Public func
  
  public func decrypt(_ encryptedText: String?) async -> String? {
    return cryptoService.decrypt(encryptedText, privateKey: systemService.getDeviceIdentifier())
  }
  
  public func encrypt(_ text: String?, publicKey: String) -> String? {
    return cryptoService.encrypt(text, publicKey: publicKey)
  }
  
  public func decrypt(_ encryptedData: Data?) async -> Data? {
    return cryptoService.decrypt(encryptedData, privateKey: systemService.getDeviceIdentifier())
  }
  
  public func encrypt(_ data: Data?, publicKey: String) -> Data? {
    return cryptoService.encrypt(data, publicKey: publicKey)
  }
  
  public func publicKey(from privateKey: String) -> String? {
    return cryptoService.publicKey(from: privateKey)
  }
}
