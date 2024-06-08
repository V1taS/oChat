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
import MessengerSDK

final class RootCoordinator: Coordinator<Void, Void> {
  
  // MARK: - Private variables
  
  private var services: IApplicationServices
  
  private var mainFlowCoordinator: MainFlowCoordinator?
  private var initialFlowCoordinator: InitialFlowCoordinator?
  private var authenticationFlowCoordinator: AuthenticationFlowCoordinator?
  private var torConnectScreenModule: TorConnectScreenModule?
  
  private lazy var p2pChatManager: IP2PChatManager = services.messengerService.p2pChatManager
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
    setupLaunchScreen()
  }
  
  @objc func appDidBecomeActive() {
    sessionCheck()
    passcodeNotSetInSystemIOSheck()
  }
  
  @objc func userDidScreenshot() {
    // TODO: - 🟡 Был сделан скриншот
  }
}

// MARK: - TorConnectScreenModuleOutput

extension RootCoordinator: TorConnectScreenModuleOutput {
  func refreshTorConnectService() {
    updateOnlineStatus(status: .offline)
    p2pChatManager.stop { [weak self] _ in
      self?.p2pChatManager.start(completion: { _ in })
    }
  }
  
  func torServiceConnected() {
    torConnectScreenModule?.viewController.dismiss(animated: true)
    torConnectScreenModule = nil
  }
  
  func stratTorConnectService() {
    setupSessionService()
    stratTORService()
  }
}

// MARK: - Open screen

private extension RootCoordinator {
  func openMainFlowCoordinator(isPresentScreenAnimated: Bool) {
    let mainFlowCoordinator = MainFlowCoordinator(services, isPresentScreenAnimated: isPresentScreenAnimated)
    self.mainFlowCoordinator = mainFlowCoordinator
    mainFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .lockOChat:
        self?.openAuthenticationFlowCoordinator(.loginPasscode(.loginFaceID))
      case .deleteOChat:
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
        self?.openTorConnectScreenModule()
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
        self?.openTorConnectScreenModule()
      case .failure:
        break
      }
      self?.authenticationFlowCoordinator = nil
    }
    authenticationFlowCoordinator.start(parameter: state)
  }
  
  func openTorConnectScreenModule() {
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
      guard let self else { return }
      var torConnectScreenModule = TorConnectScreenAssembly().createModule(services: services)
      self.torConnectScreenModule = torConnectScreenModule
      torConnectScreenModule.input.moduleOutput = self
      UIViewController.topController?.presentFullScreen(torConnectScreenModule.viewController)
    }
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
      
      services.messengerService.modelHandlerService.getAppSettingsModel { [weak self] model in
        guard let self, model.appPassword != nil else {
          return
        }
        openAuthenticationFlowCoordinator(.loginPasscode(.loginFaceID))
        mainFlowCoordinator = nil
      }
    }
  }
  
  func setupLaunchScreen() {
    guard !isFirstLaunchScreen() else {
      return
    }
    
    services.messengerService.modelHandlerService.getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      
      if model.appSettingsModel.appPassword != nil {
        openAuthenticationFlowCoordinator(.loginPasscode(.loginFaceID))
      } else {
        openMainFlowCoordinator(isPresentScreenAnimated: true)
        openTorConnectScreenModule()
      }
    }
  }
  
  func sessionCheck() {
    services.messengerService.modelHandlerService.getAppSettingsModel { [weak self] model in
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
        //        notificationService.showNotification(.positive(title: "Сервер ТОР запустился"))
        updateOnlineStatus(status: .online)
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
        updateOnlineStatus(status: .offline)
        p2pChatManager.start(completion: { _ in })
        openTorConnectScreenModule()
      }
      checkServerAvailability()
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
        updateOnlineStatus(status: .inProgress)
      case .connectingProgress:
        updateOnlineStatus(status: .inProgress)
      case .connected:
        updateOnlineStatus(status: .online)
      case .stopped:
        updateOnlineStatus(status: .offline)
        openTorConnectScreenModule()
        p2pChatManager.start(completion: { _ in })
      case .refreshing:
        updateOnlineStatus(status: .inProgress)
      case .circuitsUpdated:
        break
      }
      postSessionState(state: result)
    }
  }
  
  func startServerlistener() {
    p2pChatManager.serverStateAction = { [weak self] result in
      guard let self else {
        return
      }
      
      switch result {
      case .errorStartingServer:
        updateOnlineStatus(status: .offline)
        openTorConnectScreenModule()
        p2pChatManager.stop { [weak self] _ in
          self?.p2pChatManager.start(completion: { _ in })
        }
      default: break
      }
      postServerState(state: result)
    }
  }
  
  func postSessionState(state: TorSessionState) {
    NotificationCenter.default.post(
      name: Notification.Name(NotificationConstants.sessionState),
      object: nil,
      userInfo: ["sessionState": state]
    )
  }
  
  func postServerState(state: TorServerState) {
    NotificationCenter.default.post(
      name: Notification.Name(NotificationConstants.serverState),
      object: nil,
      userInfo: ["serverState": state]
    )
  }
  
  func updateOnlineStatus(status: ContactModel.Status) {
    // Отправка уведомления о начале нового чата
    NotificationCenter.default.post(
      name: Notification.Name(NotificationConstants.didUpdateOnlineStatusName),
      object: nil,
      userInfo: ["onlineStatus": status]
    )
  }
  
  func updateListContacts() {
    // Обновляем список контактов на главном экране
    NotificationCenter.default.post(
      name: Notification.Name(NotificationConstants.updateListContacts),
      object: nil,
      userInfo: [:]
    )
  }
  
  func isFirstLaunchScreen() -> Bool {
    let defaults = UserDefaults.standard
    let hasLaunchedKey = "HasLaunchedInitialFlow"
    
    // Проверяем, была ли функция уже выполнена
    if !defaults.bool(forKey: hasLaunchedKey) {
      openInitialFlowCoordinator(isPresentScreenAnimated: true)
      // Сохраняем, что функция была выполнена
      defaults.set(true, forKey: hasLaunchedKey)
      return true
    }
    return false
  }
  
  func checkServerAvailability() {
    DispatchQueue.global().async { [weak self] in
      self?.services.messengerService.modelHandlerService.getContactModels { [weak self] contactModels in
        guard let self else { return }
        contactModels.forEach { contact in
          self.checkContactOnline(contact, attempts: .zero)
        }
      }
    }
  }
  
  func checkContactOnline(_ contact: ContactModel, attempts: Int, maxAttempts: Int = 20) {
    guard attempts < maxAttempts else {
      // Если достигли максимального количества попыток и все были неудачными, ставим статус offline и начинаем заново
      updateContactStatus(contact, isOnline: false)
      return
    }
    
    services.messengerService.p2pChatManager.checkServerAvailability(
      onionAddress: contact.onionAddress ?? ""
    ) { [weak self] isAvailable in
      guard let self = self else { return }
      
      if isAvailable {
        // Если контакт онлайн, обновляем статус и начинаем заново
        self.updateContactStatus(contact, isOnline: true)
      } else {
        // Продолжаем делать запросы
        self.checkContactOnline(contact, attempts: attempts + 1)
      }
    }
  }
  
  func updateContactStatus(_ contact: ContactModel, isOnline: Bool) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      
      if contact.status != .requested {
        services.messengerService.modelSettingsManager.setStatus(contact, isOnline ? .online : .offline) {}
        updateListContacts()
      }
    }
    
    // Рестарт проверки статуса
    checkServerAvailability()
  }
}
