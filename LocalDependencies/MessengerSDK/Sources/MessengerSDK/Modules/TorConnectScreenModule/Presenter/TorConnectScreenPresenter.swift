//
//  TorConnectScreenPresenter.swift
//  MessengerSDK
//
//  Created by Vitalii Sosin on 07.06.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class TorConnectScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateConnectionProgress: Double = 0.14
  @Published var stateSystemMessage = ""
  
  // MARK: - Internal properties
  
  weak var moduleOutput: TorConnectScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: TorConnectScreenInteractorInput
  private let factory: TorConnectScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: TorConnectScreenInteractorInput,
       factory: TorConnectScreenFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    initialSetup()
  }
  
  lazy var viewDidAppear: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    
    moduleOutput?.stratTorConnectService()
  }
  
  // MARK: - Internal func
  
  func refreshTorConnectService() {
    moduleOutput?.refreshTorConnectService()
  }
}

// MARK: - TorConnectScreenModuleInput

extension TorConnectScreenPresenter: TorConnectScreenModuleInput {}

// MARK: - TorConnectScreenInteractorOutput

extension TorConnectScreenPresenter: TorConnectScreenInteractorOutput {}

// MARK: - TorConnectScreenFactoryOutput

extension TorConnectScreenPresenter: TorConnectScreenFactoryOutput {}

// MARK: - SceneViewModel

extension TorConnectScreenPresenter: SceneViewModel {}

// MARK: - Private

private extension TorConnectScreenPresenter {
  func initialSetup() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleServerState(_:)),
      name: Notification.Name(NotificationConstants.serverState),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleSessionState(_:)),
      name: Notification.Name(NotificationConstants.sessionState),
      object: nil
    )
  }
}

// MARK: - Handle NotificationCenter

private extension TorConnectScreenPresenter {
  @objc
  func handleServerState(_ notification: Notification) {
    if let serverState = notification.userInfo?["serverState"] as? TorServerState {
      switch serverState {
      case let .serverIsRunning(onPort):
        stateSystemMessage = "serverIsRunning on port: \(onPort)"
      case .errorStartingServer(error: let error):
        stateSystemMessage = "errorStartingServer"
      case .didAcceptNewSocket:
        stateSystemMessage = "didAcceptNewSocket"
      case .didSentResponse:
        stateSystemMessage = "didSentResponse"
      case .socketDidDisconnect:
        stateSystemMessage = "socketDidDisconnect"
      }
    }
  }
  
  @objc
  func handleSessionState(_ notification: Notification) {
    if let sessionState = notification.userInfo?["sessionState"] as? TorSessionState {
      switch sessionState {
      case .none: break
      case .started:
        stateSystemMessage = "started"
      case let .connectingProgress(result):
        stateConnectionProgress = Double(result / 100)
      case .connected:
        stateSystemMessage = "connected"
        moduleOutput?.torServiceConnected()
      case .stopped:
        stateSystemMessage = "stopped"
      case .refreshing:
        stateSystemMessage = "refreshing"
      case let .circuitsUpdated(status):
        stateSystemMessage = "status"
      }
    }
  }
}

// MARK: - Constants

private enum Constants {}
