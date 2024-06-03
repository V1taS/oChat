//
//  ChatView.swift
//  SwiftTor
//
//  Created by Vitalii Sosin on 02.06.2024.
//

import SwiftUI

@available(iOS 14.0, macOS 13, *)
public struct ChatView: View {
  @StateObject private var viewModel = ChatViewModel(hiddenServicePort: 12345)
  
  public init() {}
  
  public var body: some View {
    VStack(alignment: .leading) {
      // Адрес
      if let onionAddress = viewModel.onionAddress {
        HStack {
          Text("Your Address: \(onionAddress)")
            .padding()
          Button(action: {
            UIPasteboard.general.string = onionAddress
          }) {
            Text("Copy")
          }
          .padding()
        }
      } else {
        Text("Starting Tor...")
          .padding()
      }
      
      // Поле для ввода адреса собеседника и кнопка подключения
      HStack {
        TextField("Peer Address", text: $viewModel.peerAddress)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding()
        Button(action: viewModel.connect) {
          Text("Connect")
        }
        .padding()
      }
      
      // Индикатор подключения
      if viewModel.isConnected {
        Text("Connected")
          .foregroundColor(.green)
          .padding()
      } else {
        Text("Not Connected")
          .foregroundColor(.red)
          .padding()
      }
      
      // Поле для ввода сообщения и кнопка отправки
      HStack {
        TextField("Enter your message", text: $viewModel.message)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding()
        Button(action: viewModel.sendMessage) {
          Text("Send")
        }
        .padding()
      }
      
      // Список сообщений
      List(viewModel.messages, id: \.self) { message in
        Text(message)
      }
    }
    .padding()
  }
}
