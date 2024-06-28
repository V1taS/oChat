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
  
  @Published var stateConnectionTORProgress: CGFloat = .zero
  @Published var stateConnectionTOXProgress: CGFloat = .zero
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
    // TODO: -
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
      selector: #selector(handleSessionState(_:)),
      name: Notification.Name(NotificationConstants.sessionState.rawValue),
      object: nil
    )
  }
}

// MARK: - Handle NotificationCenter

private extension TorConnectScreenPresenter {
  @objc
  func handleSessionState(_ notification: Notification) {
    if let sessionState = notification.userInfo?["sessionState"] as? TorSessionState {
      switch sessionState {
      case .none: break
      case .started:
        stateSystemMessage = "Started"
      case let .connectingProgress(result):
        stateConnectionTORProgress = Double(result / 100)
      case .connected:
        stateSystemMessage = "Connected"
      case .stopped:
        stateSystemMessage = "Stopped"
      case .refreshing:
        stateSystemMessage = "Refreshing"
      }
    }
  }
}

// MARK: - Constants

private enum Constants {}
