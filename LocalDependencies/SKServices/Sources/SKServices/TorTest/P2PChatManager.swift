//
//  P2PChatManager.swift
//  SwiftTor
//
//  Created by Vitalii Sosin on 02.06.2024.
//

import SwiftUI

@available(iOS 13.0, macOS 13, *)
public class P2PChatManager: ObservableObject {
  private var webSocketTask: URLSessionWebSocketTask?
  var torManager: TorHelper = TorHelper()
  @Published public var messages: [String] = []
  @Published public var isConnected: Bool = false
  @Published var onionAddress: String?
  private var server: TorServer?
  
  init() {
    torManager.start { [weak self] _ in
      self?.onionAddress = self?.torManager.getOnionAddress()
      let server = TorServer()
      server.messageAction = { message in
        self?.messages.append(message)
      }
      self?.server = server
    }
  }
  
  public func connect(to onionAddress: String) {
    guard let url = URL(string: "ws://\(onionAddress):80") else {
      print("❌ Invalid onion address")
      return
    }
    
    webSocketTask = torManager.session.webSocketTask(with: url)
    webSocketTask?.resume()
    isConnected = true
    self.onionAddress = torManager.getOnionAddress()
    receiveMessage()
  }
  
  public func sendMessage(_ message: String, peerAddress: String) {
    sendMessage(message, peerAddress: peerAddress)
//    let message = URLSessionWebSocketTask.Message.string(message)
//    print("✅ sending \(message)")
////    sendMessage(to: peerAddress, message: message)
//    webSocketTask?.send(message) { error in
//      print("🟡 sendMessage \(message)")
//      if let error = error {
//        print("❌ Failed to send message: \(error)")
//      }
//    }
  }
  
  private func receiveMessage() {
    webSocketTask?.receive { [weak self] result in
      switch result {
      case .failure(let error):
        print("❌ Failed to receive message: \(error)")
        self?.isConnected = false
      case .success(let message):
        switch message {
        case .string(let text):
          DispatchQueue.main.async {
            self?.messages.append(text)
            print("✅ success")
          }
        case .data(let data):
          print("Received binary message: \(data)")
          print("✅ Received binary message")
        @unknown default:
          fatalError()
        }
        
        self?.isConnected = true
        self?.receiveMessage()
      }
    }
  }
  
  public func disconnect() {
    webSocketTask?.cancel(with: .goingAway, reason: nil)
    isConnected = false
  }
  
  private func sendMessage(to onionAddress: String, message: String) {
    guard let url = URL(string: "http://\(onionAddress):80") else {
      print("❌ Неверный URL")
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.httpBody = message.data(using: .utf8)
    
    let task = torManager.session.dataTask(with: request) { data, response, error in
      if let error = error {
        print("❌ Ошибка подключения: \(error)")
      } else if let data = data, let responseString = String(data: data, encoding: .utf8) {
        print("✅ Ответ сервера: \(responseString)")
      }
    }
    task.resume()
  }
}
