//
//  ChatViewModel.swift
//  SwiftTor
//
//  Created by Vitalii Sosin on 02.06.2024.
//

import SwiftUI
import Combine

@available(iOS 13.0, macOS 13, *)
class ChatViewModel: ObservableObject {
  @Published var chatManager: P2PChatManager
  @Published var onionAddress: String?
  @Published var peerAddress: String = "4ckul7ey4umnbatzijc52amtac4exylygizsr7fzdlqjbqsmf65a25id.onion"
  @Published var isConnected: Bool = false
  @Published var message: String = ""
  @Published var messages: [String] = ["sdfv"]
  
  private var cancellables = Set<AnyCancellable>()
  
  init(hiddenServicePort: Int) {
    self.chatManager = P2PChatManager()
    
    self.chatManager.$onionAddress
      .assign(to: \.onionAddress, on: self)
      .store(in: &cancellables)
    
    self.chatManager.$messages
      .assign(to: \.messages, on: self)
      .store(in: &cancellables)
    
    self.chatManager.$isConnected
      .assign(to: \.isConnected, on: self)
      .store(in: &cancellables)
  }
  
  func connect() {
    chatManager.connect(to: peerAddress)
  }
  
  func sendMessage() {
    chatManager.sendMessage(message, peerAddress: peerAddress)
    message = ""
  }
}
