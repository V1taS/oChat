//
//  MessengerService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 31.05.2024.
//

import Foundation
import SKAbstractions

@available(iOS 16.0, *)
public final class MessengerService: IMessengerService {
  
  public static let shared = MessengerService()
  
  private init() {}
  
  public var p2pChatManager: any IP2PChatManager {
    P2PChatManager.shared
  }
  
  public var modelSettingsManager: IMessengerModelSettingsManager {
    messengerService
  }
  
  public var modelHandlerService: IMessengerModelHandlerService {
    messengerService
  }
  
  public var appSettingsManager: IAppSettingsManager {
    messengerService
  }
}

private let messengerService = MessengerModelHandlerService()
