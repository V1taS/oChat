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
  
  @Published var stateConnectionProgress: Double = .zero
  @Published var stateSystemMessage = ""
  
  @Published var stateTestPrigressTor: CGFloat = .zero
  @Published var stateTestPrigressTox: CGFloat = .zero
  private var torTimer: Timer?
  private var toxTimer: Timer?
  
  func startProgress() {
    // Начинаем с прогресса stateTestPrigressTor
    var torProgress: CGFloat = .zero
    let torInterval = 15.0 / 150.0 // 15 секунд, 150 шагов
    
    torTimer = Timer.scheduledTimer(withTimeInterval: torInterval, repeats: true) { timer in
      if torProgress < 1.0 {
        torProgress += 1 / 150.0
        self.stateTestPrigressTor = torProgress
      } else {
        timer.invalidate()
        self.startToxProgress()
      }
    }
  }
  
  private func startToxProgress() {
    // Переходим к прогрессу stateTestPrigressTox
    var toxProgress: CGFloat = .zero
    let toxInterval = 5.0 / 50.0 // 5 секунд, 50 шагов
    
    toxTimer = Timer.scheduledTimer(withTimeInterval: toxInterval, repeats: true) { timer in
      if toxProgress < 1.0 {
        toxProgress += 1 / 50.0
        self.stateTestPrigressTox = toxProgress
      } else {
        timer.invalidate()
      }
    }
  }
  
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
    startProgress()
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
  func handleServerState(_ notification: Notification) {
    if let serverState = notification.userInfo?["serverState"] as? TorServerState {
      switch serverState {
      case let .serverIsRunning(onPort):
        print("✅ ServerIsRunning on port: \(onPort)")
      case let .errorStartingServer(error):
        print("❌ \(error)")
      case .didAcceptNewSocket:
        print("✅ DidAcceptNewSocket")
      case .didSentResponse:
        print("✅ didSentResponse")
      case .socketDidDisconnect:
        print("🟡 socketDidDisconnect")
      }
    }
  }
  
  @objc
  func handleSessionState(_ notification: Notification) {
    if let sessionState = notification.userInfo?["sessionState"] as? TorSessionState {
      switch sessionState {
      case .none: break
      case .started:
        stateSystemMessage = "Started"
      case let .connectingProgress(result):
        stateConnectionProgress = Double(result / 100)
      case .connected:
        stateSystemMessage = "Connected"
        moduleOutput?.torServiceConnected()
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
