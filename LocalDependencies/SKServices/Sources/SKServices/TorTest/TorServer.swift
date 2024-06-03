//
//  Server.swift
//  SKServices
//
//  Created by Vitalii Sosin on 03.06.2024.
//

import Foundation
import CocoaAsyncSocket

public final class TorServer: NSObject, GCDAsyncSocketDelegate {
  var socket: GCDAsyncSocket?
  var connectedSockets: [GCDAsyncSocket] = []
  var messageAction: ((String) -> Void)?
  
  override init() {
    super.init()
    socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    do {
      try socket?.accept(onPort: 80)
      print("✅ Server is running on port 80")
    } catch let error {
      print("❌ Error starting server: \(error)")
    }
  }
  
  public func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
    print("🟡 Accepted new connection")
    connectedSockets.append(newSocket)
    newSocket.delegate = self
    newSocket.readData(withTimeout: -1, tag: 0)
  }
  
  public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
    if let request = String(data: data, encoding: .utf8) {
      print("🟢 Received request: \(request)")
      
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
              print("🟢 Body of POST request: \(bodyLines)")
              messageAction?(bodyLines)
              
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
  
  
  public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
    print("🟢 Sent response")
  }
  
  public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
    if let index = connectedSockets.firstIndex(of: sock) {
      connectedSockets.remove(at: index)
    }
    print("🔴 Disconnected")
  }
}
