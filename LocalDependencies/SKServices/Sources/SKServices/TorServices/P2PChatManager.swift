//
//  P2PChatManager.swift
//  SwiftTor
//
//  Created by Vitalii Sosin on 02.06.2024.
//

import SwiftUI
import SKAbstractions

@available(iOS 16.0, *)
public final class P2PChatManager: IP2PChatManager {
  
  // MARK: - Public properties
  
  public static let shared = P2PChatManager()
  
  public var serverStateAction: ((TorServerState) -> Void)?
  public var sessionStateAction: ((_ state: TorSessionState) -> Void)?
  
  // MARK: - Private properties
  
  private var torService: ITorService = TorService.shared
  private var torServer: TorServer?
  private let timeoutInterval: TimeInterval = 30
  
  var task: URLSessionWebSocketTask?
  
  // MARK: - Init
  
  private init() {
    torService.stateAction = { [weak self] result in
      DispatchQueue.main.async { [weak self] in
        self?.sessionStateAction?(result)
      }
    }
  }
  
  // MARK: - Public funcs
  
  // Проверка доступности сервера
  public func checkServerAvailability(
    onionAddress: String,
    completion: @escaping (_ isAvailability: Bool
    ) -> Void) {
    sendHTTPRequest(
      to: onionAddress,
      path: "/check-server",
      method: "GET",
      messengerRequest: nil
    ) { result in
      switch result {
      case .success:
        completion(true)
      case .failure:
        completion(false)
      }
    }
  }
  
  // Отправка сообщения
  public func sendMessage(
    onionAddress: String,
    messengerRequest: MessengerNetworkRequestModel?,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    retrySendMessage(
      onionAddress: onionAddress,
      messengerRequest: messengerRequest,
      path: "/send-message",
      completion: completion
    )
  }
  
  // Инициация переписки
  public func initiateChat(
    onionAddress: String,
    messengerRequest: MessengerNetworkRequestModel?,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    retrySendMessage(
      onionAddress: onionAddress,
      messengerRequest: messengerRequest,
      path: "/initiate-chat",
      completion: completion
    )
  }
  
  public func getOnionAddress(completion: ((Result<String, TorServiceError>) -> Void)?) {
    DispatchQueue.main.async { [weak self] in
      guard let self else {
        return
      }
      completion?(torService.getOnionAddress())
    }
  }
  
  public func getPrivateKey(completion: ((Result<String, TorServiceError>) -> Void)?) {
    DispatchQueue.main.async { [weak self] in
      guard let self else {
        return
      }
      completion?(torService.getPrivateKey())
    }
  }
  
  public func start(completion: ((Result<Void, TorServiceError>) -> Void)?) {
    torService.start { [weak self] result in
      let server = TorServer()
      self?.torServer = server
      
      server.stateAction = { [weak self] result in
        DispatchQueue.main.async { [weak self] in
          self?.serverStateAction?(result)
        }
      }
      
      server.start()
      
      DispatchQueue.main.async {
        completion?(result)
      }
    }
  }
  
  public func stop(completion: ((Result<Void, TorServiceError>) -> Void)?) {
    DispatchQueue.main.async { [weak self] in
      guard let self else {
        return
      }
      completion?(torService.stop())
    }
  }
}

// MARK: - Private

@available(iOS 16.0, *)
private extension P2PChatManager {
  // Универсальный метод для отправки HTTP запросов
  func sendHTTPRequest(
    to onionAddress: String,
    path: String,
    method: String,
    messengerRequest: MessengerNetworkRequestModel?,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard let url = URL(string: "http://\(onionAddress):80\(path)") else {
      DispatchQueue.main.async {
        completion(.failure(URLError(.badURL)))
      }
      return
    }
    var request = URLRequest(url: url)
    request.timeoutInterval = timeoutInterval
    request.httpMethod = method
    
    let encoder = JSONEncoder()
    
    if let messengerRequestDTO = messengerRequest?.mapToDTO(),
       let jsonData = try? encoder.encode(messengerRequestDTO) {
      request.httpBody = jsonData
      request.setValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
    }
    
    let task = torService.getSession().dataTask(with: request) { _, response, error in
      DispatchQueue.main.async {
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
          DispatchQueue.main.async {
            completion(.success(()))
          }
        } else if let error = error {
          DispatchQueue.main.async {
            completion(.failure(error))
          }
        } else {
          DispatchQueue.main.async {
            completion(.failure(URLError(.badServerResponse)))
          }
        }
      }
    }
    task.resume()
  }
  
  func retrySendMessage(
    onionAddress: String,
    messengerRequest: MessengerNetworkRequestModel?,
    path: String,
    currentAttempt: Int = 0,
    maxAttempts: Int = 10,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    sendHTTPRequest(
      to: onionAddress,
      path: path,
      method: "POST",
      messengerRequest: messengerRequest
    ) { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case .success:
        print("✅ Сообщение успешно отправлено")
        completion(.success(()))
      case let .failure(error):
        if currentAttempt < maxAttempts - 1 {
          print("Ошибка отправки сообщения, попытка \(currentAttempt + 1)")
          self.retrySendMessage(
            onionAddress: onionAddress,
            messengerRequest: messengerRequest,
            path: path,
            currentAttempt: currentAttempt + 1,
            maxAttempts: maxAttempts,
            completion: completion
          )
        } else {
          print("Достигнуто максимальное количество попыток Отправить запрос")
          completion(.failure(error))
        }
      }
    }
  }
}
