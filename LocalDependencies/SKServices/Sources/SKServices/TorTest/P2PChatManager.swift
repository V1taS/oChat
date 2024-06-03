//
//  P2PChatManager.swift
//  SwiftTor
//
//  Created by Vitalii Sosin on 02.06.2024.
//

import SwiftUI
import SKAbstractions

public final class P2PChatManager: IP2PChatManager {
  
  // MARK: - Public properties
  
  public var serverStateAction: ((TorServerState) -> Void)?
  public var sessionStateAction: ((_ state: TorSessionState) -> Void)?
  public var stateErrorServiceAction: ((_ state: Result<Void, TorServiceError>) -> Void)?
  
  // MARK: - Private properties
  
  private var torService: ITorService = TorService()
  private var torServer: ITorServer?
  
  // MARK: - Init
  
  public init() {
    torService.start { [weak self] result in
      self?.stateErrorServiceAction?(result)
      
      guard case .success(()) = result else {
        return
      }
      let server = TorServer()
      self?.serverStateAction = server.stateAction
      self?.sessionStateAction = self?.torService.stateAction
      self?.torServer = server
    }
  }
  
  // MARK: - Public funcs
  
  public func sendMessage(
    _ message: String,
    peerAddress: String,
    completion: ((Result<Void, Error>) -> Void)?
  ) {
    sendMessage(
      onionAddress: peerAddress,
      message: message,
      completion: completion
    )
  }
  
  public func getOnionAddress() -> Result<String, TorServiceError> {
    torService.getOnionAddress()
  }
  
  public func getPrivateKey() -> Result<String, TorServiceError> {
    torService.getPrivateKey()
  }
  
  public func start(completion: ((Result<Void, TorServiceError>) -> Void)?) {
    torService.start(completion: completion)
  }
  
  public func stop() -> Result<Void, TorServiceError> {
    torService.stop()
  }
}

// MARK: - Private

private extension P2PChatManager {
  private func sendMessage(
    onionAddress: String,
    message: String,
    completion: ((Result<Void, Error>) -> Void)?
  ) {
    guard let url = URL(string: "http://\(onionAddress):80") else {
      completion?(.failure(URLError(.badURL)))
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.httpBody = message.data(using: .utf8)
    
    let task = torService.getSession().dataTask(with: request) { data, response, error in
      if error != nil {
        completion?(.failure(URLError(.unknown)))
      } else {
        completion?(.success(()))
      }
    }
    task.resume()
  }
}
