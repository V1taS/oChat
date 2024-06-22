////
////  Server.swift
////  SKServices
////
////  Created by Vitalii Sosin on 03.06.2024.
////
//
//import Foundation
//import CocoaAsyncSocket
//import SKAbstractions
//
///// Класс, реализующий сервер Tor с использованием делегирования `GCDAsyncSocket`.
//@available(iOS 16.0, *)
//final class TorServer: NSObject, GCDAsyncSocketDelegate, ITorServer {
//  
//  // MARK: - Public properties
//  
//  public var stateAction: ((TorServerState) -> Void)?
//  
//  // MARK: - Private properties
//  
//  private var socket: GCDAsyncSocket?
//  private var connectedSockets: [GCDAsyncSocket] = []
//  private let onPort: UInt16 = 80
//  
//  // MARK: - Initialization and Start
//  
//  func start() {
//    socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.global())
//    do {
//      stateAction?(.serverIsRunning(onPort: onPort))
//      try socket?.accept(onPort: onPort)
//    } catch let error {
//      stateAction?(.errorStartingServer(error: "Error starting server: \(error)"))
//    }
//  }
//  
//  // MARK: - GCDAsyncSocketDelegate Methods
//  
//  func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
//    stateAction?(.didAcceptNewSocket)
//    connectedSockets.append(newSocket)
//    newSocket.delegate = self
//    newSocket.readData(withTimeout: -1, tag: 0)
//  }
//  
//  func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
//    guard let request = String(data: data, encoding: .utf8),
//          let body = extractBody(from: request) else {
//      sock.readData(withTimeout: -1, tag: 0)
//      return
//    }
//    
//    if request.contains("POST /send-message") {
//      processSendMessage(body.data(using: .utf8) ?? Data(), socket: sock)
//    } else if request.contains("POST /initiate-chat") {
//      processInitiateChat(body.data(using: .utf8) ?? Data(), socket: sock)
//    }
//    
//    sock.readData(withTimeout: -1, tag: 0)
//  }
//  
//  func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
//    if let index = connectedSockets.firstIndex(of: sock) {
//      connectedSockets.remove(at: index)
//      stateAction?(.socketDidDisconnect)
//    }
//  }
//}
//// MARK: - Private
//
//@available(iOS 16.0, *)
//private extension TorServer {
//  func extractText(from messages: String) -> String {
//    guard let range = messages.range(of: "deflate\r\n\r\n") else {
//      return messages
//    }
//    let firstPart = String(messages[..<range.upperBound])
//    let secondPart = String(messages[range.upperBound...])
//    return secondPart
//  }
//  
//  func processSendMessage(_ bodyData: Data, socket: GCDAsyncSocket) {
//    guard let request = try? JSONDecoder().decode(MessengerNetworkRequestDTO.self, from: bodyData) else {
//      let response = createResponse(statusCode: "400 Bad Request", message: "Invalid Message Format")
//      socket.write(response, withTimeout: -1, tag: 0)
//      return
//    }
//    
//    // Отправка уведомления о получении нового сообщения
//    NotificationCenter.default.post(
//      name: Notification.Name(NotificationConstants.didReceiveMessage.rawValue),
//      object: nil,
//      userInfo: ["data": request.mapToModel()]
//    )
//    
//    // Отправка ответа на успешное получение сообщения
//    let response = createResponse(statusCode: "200 OK", message: "Message Received")
//    socket.write(response, withTimeout: -1, tag: 0)
//  }
//  
//  func processInitiateChat(_ bodyData: Data, socket: GCDAsyncSocket) {
//    guard let request = try? JSONDecoder().decode(MessengerNetworkRequestDTO.self, from: bodyData) else {
//      let response = createResponse(statusCode: "400 Bad Request", message: "Invalid Chat Request Format")
//      socket.write(response, withTimeout: -1, tag: 0)
//      return
//    }
//    
//    // Отправка ответа на успешное начало чата
//    let response = createResponse(statusCode: "200 OK", message: "Chat Initiated")
//    socket.write(response, withTimeout: -1, tag: 0)
//  }
//  
//  func createResponse(statusCode: String, message: String) -> Data {
//    let response = "HTTP/1.1 \(statusCode)\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: \(message.utf8.count)\r\n\r\n\(message)"
//    return Data(response.utf8)
//  }
//  
//  /// Извлекает тело HTTP-запроса из полного текста запроса.
//  /// - Parameter request: Полный текст HTTP-запроса.
//  /// - Returns: Тело запроса в виде `String?`, если оно существует.
//  func extractBody(from request: String) -> String? {
//    print("extractBody ✅ \(request)")
//    // Разделитель между заголовками и телом запроса в HTTP - двойной перенос строки
//    let separator = "\r\n\r\n"
//    guard let bodyStartIndex = request.range(of: separator)?.upperBound else {
//      return nil
//    }
//    let body = request[bodyStartIndex...]
//    return String(body)
//  }
//}
