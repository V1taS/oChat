//
//  MessengerListScreenModuleAssembly.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions
import SKManagers

/// Сборщик `MessengerListScreenModule`
public final class MessengerListScreenModuleAssembly {
  
  // MARK: - Init
  
  public init() {}
  
  // MARK: - Public funcs
  
  /// Собирает модуль `MessengerListScreenModule`
  /// - Returns: Cобранный модуль `MessengerListScreenModule`
  public func createModule(services: IApplicationServices) -> MessengerListScreenModuleModule {
    let interactor = createInteractor(services: services, isMock: false)
    return assembleModule(interactor: interactor)
  }
  
  /// Собирает модуль для Демо `MessengerListScreenModule`
  /// - Returns: Cобранный модуль `MessengerListScreenModule`
  public func createMockModule(services: IApplicationServices) -> MessengerListScreenModuleModule {
    let interactor = createInteractor(services: services, isMock: true)
    return assembleModule(interactor: interactor)
  }
}

// MARK: - Private

private extension MessengerListScreenModuleAssembly {
  /// Метод для создания интерактора
  /// - Parameter services: Сервисы приложения
  /// - Parameter isMock: Флаг для создания мокового интерактора
  /// - Returns: Интерактор модуля
  func createInteractor(services: IApplicationServices, isMock: Bool) -> MessengerListScreenModuleInteractorInput {
    let cryptoManager = CryptoManager(
      cryptoService: services.accessAndSecurityManagementService.cryptoService,
      systemService: services.userInterfaceAndExperienceService.systemService
    )
    let contactManager = ContactManager(
      modelHandlerService: services.messengerService.modelHandlerService,
      modelSettingsManager: services.messengerService.modelSettingsManager,
      p2pChatManager: services.messengerService.p2pChatManager
    )
    let notificationManager = NotificationManager(
      permissionService: services.accessAndSecurityManagementService.permissionService,
      pushNotificationService: services.pushNotificationService,
      p2pChatManager: services.messengerService.p2pChatManager,
      modelSettingsManager: services.messengerService.modelSettingsManager,
      modelHandlerService: services.messengerService.modelHandlerService
    )
    let fileManager = SKFileManager(
      dataManagementService: services.dataManagementService.dataManagerService,
      zipArchiveService: services.dataManagementService.zipArchiveService
    )
    let messageManager = MessageManager(
      p2pChatManager: services.messengerService.p2pChatManager,
      modelSettingsManager: services.messengerService.modelSettingsManager
    )
    let settingsManager = SettingsManager(
      modelHandlerService: services.messengerService.modelHandlerService,
      systemService: services.userInterfaceAndExperienceService.systemService,
      notificationService: services.userInterfaceAndExperienceService.notificationService
    )
    let toxManager = ToxManager(
      p2pChatManager: services.messengerService.p2pChatManager,
      modelHandlerService: services.messengerService.modelHandlerService,
      modelSettingsManager: services.messengerService.modelSettingsManager
    )
    let interfaceManager = InterfaceManager()
    
    if isMock {
      return MessengerListScreenModuleDemoInteractor(
        services: services,
        cryptoManager: cryptoManager,
        contactManager: contactManager,
        notificationManager: notificationManager,
        fileManager: fileManager,
        messageManager: messageManager,
        settingsManager: settingsManager,
        toxManager: toxManager,
        interfaceManager: interfaceManager
      )
    } else {
      return MessengerListScreenModuleInteractor(
        services: services,
        cryptoManager: cryptoManager,
        contactManager: contactManager,
        notificationManager: notificationManager,
        fileManager: fileManager,
        messageManager: messageManager,
        settingsManager: settingsManager,
        toxManager: toxManager,
        interfaceManager: interfaceManager
      )
    }
  }
  
  /// Метод для сборки модуля
  /// - Parameter interactor: Интерактор, используемый для создания модуля
  /// - Returns: Cобранный модуль `MessengerListScreenModule`
  func assembleModule(interactor: MessengerListScreenModuleInteractorInput) -> MessengerListScreenModuleModule {
    var interactor = interactor
    let factory = MessengerListScreenModuleFactory()
    let presenter = MessengerListScreenModulePresenter(
      interactor: interactor,
      factory: factory,
      incomingDataManager: IncomingDataManager.shared
    )
    let view = MessengerListScreenModuleView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
