//
//  Server.swift
//  SKServices
//
//  Created by Vitalii Sosin on 03.06.2024.
//

import Foundation
import CocoaAsyncSocket
import SKAbstractions

/// Класс, реализующий сервер Tor с использованием делегирования `GCDAsyncSocket`.
final class TorServer: NSObject, GCDAsyncSocketDelegate, ITorServer {
  
  // MARK: - Public properties
  
  public var stateAction: ((TorServerState) -> Void)?
  
  // MARK: - Private properties
  
  private var socket: GCDAsyncSocket?
  private var connectedSockets: [GCDAsyncSocket] = []
  
  // MARK: - Init
  
  public init(onPort: UInt16 = 80) {
    super.init()
    socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.global())
    do {
      try socket?.accept(onPort: onPort)
      stateAction?(.serverIsRunning(onPort: onPort))
    } catch let error {
      stateAction?(.errorStartingServer(error: "Error starting server: \(error)"))
    }
  }
  
  func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
    stateAction?(.didAcceptNewSocket)
    connectedSockets.append(newSocket)
    newSocket.delegate = self
    newSocket.readData(withTimeout: -1, tag: 0)
  }
  
  func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
    stateAction?(.didReadData(data))
    
    if let request = String(data: data, encoding: .utf8) {
      // Разбираем HTTP запрос для определения метода и тела
      let lines = request.split(separator: "\r\n", omittingEmptySubsequences: false)
      if lines.count > 0 {
        let requestLine = lines[0].split(separator: " ")
        if requestLine.count > 1 {
          let method = requestLine[0]
          if method == "POST" {
            // Обрабатываем POST запрос
            // Находим пустую строку, отделяющую заголовки от тела
            if let bodyIndex = lines.firstIndex(where: { $0.isEmpty }) {
              let bodyLines = lines[(bodyIndex + 1)...].joined(separator: "\n")
              stateAction?(.didReceiveMessage(bodyLines))
              
              // Ответ на POST запрос
              let response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: \(bodyLines.count)\r\n\r\n\(bodyLines)"
              if let responseData = response.data(using: .utf8) {
                sock.write(responseData, withTimeout: -1, tag: 0)
              }
            }
          } else {
            // Обработка других типов запросов или отправка общего ответа
            let response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 13\r\n\r\nHello, oChat!\r\n"
            if let responseData = response.data(using: .utf8) {
              sock.write(responseData, withTimeout: -1, tag: 0)
            }
          }
        }
      }
    }
    sock.readData(withTimeout: -1, tag: 0)
  }
  
  func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
    stateAction?(.didSentResponse)
  }
  
  func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
    if let index = connectedSockets.firstIndex(of: sock) {
      connectedSockets.remove(at: index)
      stateAction?(.socketDidDisconnect)
    }
  }
}
