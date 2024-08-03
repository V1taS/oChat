//
//  MessageManager.swift
//  SKManagers
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle
import SKFoundation

public final class MessageManager: IMessageManager {
  
  // MARK: - Private properties
  
  private let p2pChatManager: IP2PChatManager
  private let modelSettingsManager: IMessengerModelSettingsManager
  
  // MARK: - Init
  
  public init(
    p2pChatManager: IP2PChatManager,
    modelSettingsManager: IMessengerModelSettingsManager
  ) {
    self.p2pChatManager = p2pChatManager
    self.modelSettingsManager = modelSettingsManager
  }
  
  // MARK: - Public funcs
  
  public func sendMessage(toxPublicKey: String, messengerRequest: MessengerNetworkRequestModel?) async -> Int32? {
    guard let messengerRequest else {
      return nil
    }
    let dto = messengerRequest.mapToDTO()
    guard let json = createJSONString(from: dto) else {
      return nil
    }
    
    let messageID = try? await p2pChatManager.sendMessage(to: toxPublicKey, message: json, messageType: .normal)
    guard let messageID else {
      return nil
    }
    await saveToxState()
    return messageID
  }
  
  public func sendFile(
    toxPublicKey: String,
    recipientPublicKey: String,
    recordModel: MessengeRecordingModel?,
    messengerRequest: MessengerNetworkRequestModel,
    files: [URL]
  ) async {
    await p2pChatManager.sendFile(
      toxPublicKey: toxPublicKey,
      recipientPublicKey: recipientPublicKey,
      model: messengerRequest.mapToDTO(),
      recordModel: recordModel,
      files: files
    )
  }
  
  public func initialChat(
    senderAddress: String,
    messengerRequest: MessengerNetworkRequestModel?
  ) async -> Int32? {
    guard let messengerRequest else { return nil }
    
    let dto = messengerRequest.mapToDTO()
    guard let json = createJSONString(from: dto) else { return nil }
    
    guard let contactID = await p2pChatManager.addFriend(address: senderAddress, message: json) else { return nil }
    await saveToxState()
    print("✅ Запрос отправлен")
    return contactID
  }
}

// MARK: - Private

private extension MessageManager {
  func createJSONString(from dto: MessengerNetworkRequestDTO) -> String? {
    let encoder = JSONEncoder()
    
    do {
      let jsonData = try encoder.encode(dto)
      guard let jsonString = String(data: jsonData, encoding: .utf8) else {
        print("Ошибка преобразования данных JSON в строку.")
        return nil
      }
      return jsonString
    } catch {
      print("Ошибка кодирования модели в JSON: \(error)")
      return nil
    }
  }
  
  func saveToxState() async {
    let stateAsString = await p2pChatManager.toxStateAsString()
    await modelSettingsManager.setToxStateAsString(stateAsString)
  }
}
