//
//  ToxManager.swift
//  SKManagers
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle
import SKFoundation

public final class ToxManager: IToxManager {
  
  // MARK: - Private properties
  
  private let p2pChatManager: IP2PChatManager
  private let modelHandlerService: IMessengerModelHandlerService
  private let modelSettingsManager: IMessengerModelSettingsManager
  private var cacheFriendStatus: [String: Bool] = [:]
  
  // MARK: - Init
  
  public init(
    p2pChatManager: IP2PChatManager,
    modelHandlerService: IMessengerModelHandlerService,
    modelSettingsManager: IMessengerModelSettingsManager
  ) {
    self.p2pChatManager = p2pChatManager
    self.modelHandlerService = modelHandlerService
    self.modelSettingsManager = modelSettingsManager
  }
  
  // MARK: - Public funcs
  
  public func startPeriodicFriendStatusCheck(completion: (() -> Void)?) async {
    await p2pChatManager.startPeriodicFriendStatusCheck { [weak self] friendStatus in
      guard let self else { return }
      if cacheFriendStatus != friendStatus {
        cacheFriendStatus = friendStatus
        for (publicKey, isOnline) in friendStatus {
          Task { [weak self] in
            guard let self else { return }
            let contactModel = await self.getContactModelsFrom(toxPublicKey: publicKey)
            var updateContact = contactModel
            if updateContact?.status != .initialChat || updateContact?.status != .requestChat {
              updateContact?.status = isOnline ? .online : .offline
            }
            if !isOnline {
              updateContact?.isTyping = false
            }
            
            if let updateContact {
              await self.modelHandlerService.saveContactModel(updateContact)
              
              DispatchQueue.main.async {
                completion?()
                print("Friend \(publicKey) is \(isOnline ? "🟢🟢🟢 online" : "🔴🔴🔴 offline")")
              }
            }
          }
        }
      }
    }
  }
  
  public func startToxService() async {
    let messengerModel = await modelHandlerService.getMessengerModel()
    let toxStateAsString = messengerModel.appSettingsModel.toxStateAsString
    
    do {
      try? await p2pChatManager.start(saveDataString: toxStateAsString)
      
      if toxStateAsString == nil {
        let stateAsString = await p2pChatManager.toxStateAsString()
        await modelSettingsManager.setToxStateAsString(stateAsString)
      }
    }
  }
  
  public func getToxAddress() async -> String? {
    return await p2pChatManager.getToxAddress()
  }
  
  public func getToxPublicKey() async -> String? {
    return await p2pChatManager.getToxPublicKey()
  }
  
  public func getToxPublicKey(from address: String) -> String? {
    return p2pChatManager.getToxPublicKey(from: address)
  }
  
  public func confirmFriendRequest(with publicToxKey: String) async -> String? {
    return await p2pChatManager.confirmFriendRequest(with: publicToxKey)
  }
  
  public func setSelfStatus(isOnline: Bool) async {
    await p2pChatManager.setSelfStatus(isOnline: isOnline)
  }
  
  public func setUserIsTyping(_ isTyping: Bool, to toxPublicKey: String) async -> Result<Void, Error> {
    return await p2pChatManager.setUserIsTyping(isTyping, to: toxPublicKey)
  }
}

// MARK: - Private

private extension ToxManager {
  func getContactModelsFrom(toxPublicKey: String) async -> ContactModel? {
    let contactModels = await modelHandlerService.getContactModels()
    return contactModels.first { $0.toxPublicKey == toxPublicKey }
  }
}
