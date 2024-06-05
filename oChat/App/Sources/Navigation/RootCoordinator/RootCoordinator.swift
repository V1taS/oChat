//
//  RootCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 16.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKAbstractions
import SKStyle
import UIKit
import AuthenticationSDK

final class RootCoordinator: Coordinator<Void, Void> {
  
  // MARK: - Private variables
  
  private var services: IApplicationServices
  
  private var mainFlowCoordinator: MainFlowCoordinator?
  private var initialFlowCoordinator: InitialFlowCoordinator?
  private var authenticationFlowCoordinator: AuthenticationFlowCoordinator?
  private lazy var p2pChatManager: IP2PChatManager = services.p2pChatManager
  private var notificationService: INotificationService {
    services.userInterfaceAndExperienceService.notificationService
  }
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы приложения
  init(_ services: IApplicationServices) {
    self.services = services
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Internal func
  
  override func start(parameter: Void) {
    setupSessionService()
    setupLaunchScreen()
    stratTORService()
  }
  
  @objc func appDidBecomeActive() {
    sessionCheck()
    passcodeNotSetInSystemIOSheck()
  }
  
  @objc func userDidScreenshot() {
    // TODO: - 🟡 Был сделан скриншот
  }
}

// MARK: - Open screen

private extension RootCoordinator {
  func openMainFlowCoordinator(isPresentScreenAnimated: Bool) {
    let mainFlowCoordinator = MainFlowCoordinator(services, isPresentScreenAnimated: isPresentScreenAnimated)
    self.mainFlowCoordinator = mainFlowCoordinator
    mainFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .exitWallet:
        self?.openInitialFlowCoordinator(isPresentScreenAnimated: true)
      }
      self?.mainFlowCoordinator = nil
    }
    mainFlowCoordinator.start()
  }
  
  func openInitialFlowCoordinator(isPresentScreenAnimated: Bool) {
    let initialFlowCoordinator = InitialFlowCoordinator(services, isPresentScreenAnimated: isPresentScreenAnimated)
    self.initialFlowCoordinator = initialFlowCoordinator
    initialFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .success:
        self?.openMainFlowCoordinator(isPresentScreenAnimated: true)
      case .failure:
        break
      }
      self?.initialFlowCoordinator = nil
    }
    initialFlowCoordinator.start()
  }
  
  func openAuthenticationFlowCoordinator(_ state: AuthenticationScreenState) {
    let authenticationFlowCoordinator = AuthenticationFlowCoordinator(services)
    self.authenticationFlowCoordinator = authenticationFlowCoordinator
    authenticationFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .success:
        self?.openMainFlowCoordinator(isPresentScreenAnimated: true)
      case .failure:
        break
      }
      self?.authenticationFlowCoordinator = nil
    }
    authenticationFlowCoordinator.start(parameter: state)
  }
}

// MARK: - Private

private extension RootCoordinator {
  func setupSessionService() {
    let notificationCenter = NotificationCenter.default
    
    notificationCenter.addObserver(
      self,
      selector: #selector(userDidScreenshot),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
    
    notificationCenter.addObserver(
      self,
      selector: #selector(appDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    
    var sessionService = services.accessAndSecurityManagementService.sessionService
    sessionService.sessionDidExpireAction = { [weak self] in
      guard let self else {
        return
      }
      
      services.dataManagementService.modelHandlerService.getAppSettingsModel { [weak self] model in
        guard let self, model.appPassword != nil else {
          return
        }
        openAuthenticationFlowCoordinator(.loginPasscode(.loginFaceID))
        mainFlowCoordinator = nil
      }
    }
  }
  
  func setupLaunchScreen() {
    openMainFlowCoordinator(isPresentScreenAnimated: true)
    //    services.dataManagementService.modelHandlerService.getoChatModel { [weak self] model in
    //      guard let self else {
    //        return
    //      }
    //
    //      if !model.wallets.isEmpty {
    //        if model.appSettingsModel.appPassword != nil {
    //          openAuthenticationFlowCoordinator(.loginPasscode(.loginFaceID))
    //        } else {
    //          openMainFlowCoordinator(isPresentScreenAnimated: true)
    //        }
    //        return
    //      }
    //
    //      openInitialFlowCoordinator(isPresentScreenAnimated: true)
    //    }
  }
  
  func sessionCheck() {
    services.dataManagementService.modelHandlerService.getAppSettingsModel { [weak self] model in
      guard let self, model.appPassword != nil else {
        return
      }
      if !services.accessAndSecurityManagementService.sessionService.isSessionActive() {
        openAuthenticationFlowCoordinator(.loginPasscode(.loginFaceID))
      }
    }
  }
  
  func passcodeNotSetInSystemIOSheck() {
    services.userInterfaceAndExperienceService.systemService.checkIfPasscodeIsSet { [weak self] result in
      guard let self else {
        return
      }
      if case let .failure(error) = result, error == .passcodeNotSet {
        services.userInterfaceAndExperienceService.notificationService.showNotification(
          .negative(
            title: OChatStrings.RootCoordinatorLocalization
              .State.Notification.PasscodeNotSet.title
          )
        )
      }
    }
  }
  
  func stratTORService() {
    startSessionlistener()
    startServerlistener()
    
    p2pChatManager.start { [weak self] result in
      guard let self else {
        return
      }
      
      switch result {
      case .success:
        notificationService.showNotification(.positive(title: "Сервер ТОР запустился"))
      case let .failure(error):
        switch error {
        case .onionAddressForTorHiddenServiceCouldNotBeLoaded:
          notificationService.showNotification(.negative(title: "Не удалось загрузить адрес onion-сервиса"))
        case .errorLoadingPrivateKey:
          notificationService.showNotification(.negative(title: "Ошибка при загрузке приватного ключа"))
        case .errorWhenDeletingKeys:
          notificationService.showNotification(.negative(title: "Ошибка при удалении ключей"))
        case let .somethingWentWrong(text):
          notificationService.showNotification(.negative(title: "Произошла непредвиденная ошибка \(text ?? "")"))
        case .failedToSetPermissions:
          notificationService.showNotification(.negative(title: "Не удалось установить права доступа"))
        case .failedToWriteTorrc:
          notificationService.showNotification(.negative(title: "Ошибка при записи файла конфигурации torrc"))
        case .failedToCreateDirectory:
          notificationService.showNotification(.negative(title: "Ошибка при создании директории"))
        case .authDirectoryPreviouslyCreated:
          notificationService.showNotification(.negative(title: "Директория авторизации уже была создана ранее"))
        case .torrcFileIsEmpty:
          notificationService.showNotification(.negative(title: "Файл конфигурации torrc пуст"))
        case .unableToAccessTheCachesDirectory:
          notificationService.showNotification(.negative(title: "Невозможно получить доступ к кэш-директории"))
        }
      }
    }
  }
  
  func startSessionlistener() {
    p2pChatManager.sessionStateAction = { [weak self] result in
      guard let self else {
        return
      }
      
      switch result {
      case .none: break
      case .started:
        notificationService.showNotification(.neutral(title: "Подключение начато, идет процесс инициализации."))
      case let .connectingProgress(progress):
        notificationService.showNotification(.neutral(title: "Прогресс подключения к TOR: \(progress)%"))
      case .connected:
        notificationService.showNotification(.positive(title: "Подключение успешно установлено."))
      case .stopped:
        notificationService.showNotification(.negative(title: "Подключение остановлено."))
      case .refreshing:
        notificationService.showNotification(.neutral(title: "Подключение обновляется."))
      }
    }
  }
  
  func startServerlistener() {
    p2pChatManager.serverStateAction = { [weak self] result in
      guard let self else {
        return
      }
      
      switch result {
      case let .serverIsRunning(onPort):
        notificationService.showNotification(.positive(title: "Сервер запущен и слушает порт: \(onPort)"))
      case let .errorStartingServer(error):
        notificationService.showNotification(.negative(title: "Произошла ошибка при запуске сервера. \(error)"))
      case .didAcceptNewSocket:
        notificationService.showNotification(.positive(title: "Сервер принял новое соединение."))
      case .didReadData:
        notificationService.showNotification(.positive(title: "Сервер прочитал данные."))
      case let .didReceiveMessage(message):
        notificationService.showNotification(.positive(title: "Сервер получил сообщение: \(message)"))
      case .didSentResponse:
        notificationService.showNotification(.positive(title: "Сервер отправил ответ."))
      case .socketDidDisconnect:
        notificationService.showNotification(.negative(title: "Соединение с собеседникомм закончилось."))
      }
    }
  }
}
