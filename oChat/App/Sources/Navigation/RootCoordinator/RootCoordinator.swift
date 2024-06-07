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
    runInitialFlowOnce()
    
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
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleMessage(_:)),
      name: Notification.Name(NotificationConstants.didReceiveMessageName),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleInitial(_:)),
      name: Notification.Name(NotificationConstants.didInitiateChatName),
      object: nil
    )
    
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
      }
      //      checkServerAvailability()
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
        //        notificationService.showNotification(.neutral(title: "Подключение начато, идет процесс инициализации."))
        updateOnlineStatus(status: .inProgress)
      case let .connectingProgress(progress):
        //        notificationService.showNotification(.neutral(title: "Прогресс подключения к TOR: \(progress)%"))
        updateOnlineStatus(status: .inProgress)
      case .connected:
        //        notificationService.showNotification(.positive(title: "Подключение успешно установлено."))
        updateOnlineStatus(status: .online)
      case .stopped:
        notificationService.showNotification(.negative(title: "Подключение остановлено."))
        updateOnlineStatus(status: .offline)
        p2pChatManager.start(completion: { _ in })
      case .refreshing:
        //        notificationService.showNotification(.neutral(title: "Подключение обновляется."))
        updateOnlineStatus(status: .inProgress)
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
        //        notificationService.showNotification(.positive(title: "Сервер запущен и слушает порт: \(onPort)"))
        break
      case let .errorStartingServer(error):
        notificationService.showNotification(.negative(title: "Произошла ошибка при запуске сервера. \(error)"))
        p2pChatManager.stop { [weak self] _ in
          self?.p2pChatManager.start(completion: { _ in })
        }
      case .didAcceptNewSocket:
        //        notificationService.showNotification(.positive(title: "Сервер принял новое соединение."))
        break
      case .didSentResponse:
        //        notificationService.showNotification(.positive(title: "Сервер отправил ответ."))
        break
      case .socketDidDisconnect:
        //        notificationService.showNotification(.negative(title: "Соединение с собеседникомм закончилось."))
        break
      }
    }
  }
  
  @objc
  func handleMessage(_ notification: Notification) {
    if let recipientMessageModel = notification.userInfo?["data"] as? MessengerNetworkRequest {
      services.messengerService.modelHandlerService.getContactModels { [weak self] contactModels in
        guard let self else { return }
        if let indexContact = contactModels.firstIndex(where: {
          $0.onionAddress == recipientMessageModel.onionAddress
        }) {
          var updatedContact = contactModels[indexContact]
          //          let decryptMessage = services.accessAndSecurityManagementService.cryptoService.decrypt(
          //            recipientMessageModel.message,
          //            privateKey: services.userInterfaceAndExperienceService.systemService.getDeviceIdentifier()
          //          )
          
          updatedContact.messenges.append(
            .init(
              messageType: .received,
              messageStatus: .delivered,
              message: recipientMessageModel.message,
              file: nil
            )
          )
          updatedContact.onionAddress = recipientMessageModel.onionAddress
          updatedContact.meshAddress = recipientMessageModel.message
          updatedContact.encryptionPublicKey = recipientMessageModel.publicKey
          updatedContact.status = .init(rawValue: recipientMessageModel.status) ?? .online
          services.messengerService.modelHandlerService.saveContactModel(updatedContact, completion: {})
        } else {
          let contact = ContactModel(
            name: nil,
            onionAddress: recipientMessageModel.onionAddress,
            meshAddress: nil,
            messenges: [
              .init(
                messageType: .received,
                messageStatus: .delivered,
                message: "",
                file: nil
              )
            ],
            status: .requested,
            encryptionPublicKey: nil,
            isPasswordDialogProtected: false
          )
          services.messengerService.modelHandlerService.saveContactModel(contact, completion: {})
        }
      }
    }
    updateListContacts()
  }
  
  @objc
  func handleInitial(_ notification: Notification) {
    if let recipientMessageModel = notification.userInfo?["initiateChat"] as? MessengerNetworkRequest {
      let contact = ContactModel(
        name: nil,
        onionAddress: recipientMessageModel.onionAddress,
        meshAddress: nil,
        messenges: [
          .init(
            messageType: .received,
            messageStatus: .delivered,
            message: "",
            file: nil
          )
        ],
        status: .requested,
        encryptionPublicKey: nil,
        isPasswordDialogProtected: false
      )
      services.messengerService.modelHandlerService.saveContactModel(contact, completion: {})
      updateListContacts()
    }
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
  
  func checkServerAvailability() {
    DispatchQueue.global().async { [weak self] in
      self?.services.messengerService.modelHandlerService.getContactModels { [weak self] contactModels in
        guard let self else { return }
        contactModels.forEach { [weak self] contact in
          guard let self else { return }
          services.messengerService.p2pChatManager.checkServerAvailability(
            onionAddress: contact.onionAddress ?? "") { [weak self] isAvailable in
              guard let self else { return }
              //              if isAvailable {
              //                DispatchQueue.main.async { [weak self] in
              //                  guard let self else { return }
              //                  services.userInterfaceAndExperienceService.notificationService
              //                    .showNotification(.positive(title: "Контакт в сети: \(contact.onionAddress ?? "")"))
              //                }
              //
              //              } else {
              //                DispatchQueue.main.async { [weak self] in
              //                  guard let self else { return }
              //                  services.userInterfaceAndExperienceService.notificationService
              //                    .showNotification(.negative(title: "Контакт не в сети: \(contact.onionAddress ?? "")"))
              //                }
              //              }
              
              services.messengerService.modelSettingsManager.setStatus(
                contact,
                isAvailable ? .online : .offline,
                completion: {}
              )
              updateListContacts()
              checkServerAvailability()
            }
        }
      }
    }
  }
  
  func runInitialFlowOnce() {
    let defaults = UserDefaults.standard
    let hasLaunchedKey = "HasLaunchedInitialFlow"
    
    // Проверяем, была ли функция уже выполнена
    if !defaults.bool(forKey: hasLaunchedKey) {
      openInitialFlowCoordinator(isPresentScreenAnimated: true)
      // Сохраняем, что функция была выполнена
      defaults.set(true, forKey: hasLaunchedKey)
      return
    }
    openMainFlowCoordinator(isPresentScreenAnimated: true)
  }
}
