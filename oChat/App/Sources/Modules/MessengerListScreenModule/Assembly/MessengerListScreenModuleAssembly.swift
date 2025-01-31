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
    let interactor = createInteractor(services: services, accessType: .main)
    return assembleModule(interactor: interactor)
  }
  
  /// Собирает модуль для Демо `MessengerListScreenModule`
  /// - Returns: Cобранный модуль `MessengerListScreenModule`
  public func createMockModule(services: IApplicationServices) -> MessengerListScreenModuleModule {
    let interactor = createInteractor(services: services, accessType: .demo)
    return assembleModule(interactor: interactor)
  }
  
  /// Собирает модуль для фейка `MessengerListScreenModule`
  /// - Returns: Cобранный модуль `MessengerListScreenModule`
  public func createFakeModule(services: IApplicationServices) -> MessengerListScreenModuleModule {
    let interactor = createInteractor(services: services, accessType: .fake)
    return assembleModule(interactor: interactor)
  }
}

// MARK: - Private

private extension MessengerListScreenModuleAssembly {
  /// Метод для создания интерактора
  /// - Parameter services: Сервисы приложения
  /// - Parameter accessType: Тип доступа
  /// - Returns: Интерактор модуля
  func createInteractor(
    services: IApplicationServices,
    accessType: AppSettingsModel.AccessType
  ) -> MessengerListScreenModuleInteractorInput {
    let cryptoManager = CryptoManager(
      cryptoService: services.accessAndSecurityManagementService.cryptoService,
      systemService: services.userInterfaceAndExperienceService.systemService
    )
    
    let contactManager = ContactManager(
      contactsDataManager: services.messengerService.contactsDataManager,
      p2pChatManager: services.messengerService.p2pChatManager
    )
    let notificationManager = NotificationManager(
      permissionService: services.accessAndSecurityManagementService.permissionService,
      pushNotificationService: services.pushNotificationService,
      appSettingsDataManager: services.messengerService.appSettingsDataManager
    )
    let fileManager = SKFileManager(
      dataManagementService: services.dataManagementService.dataManagerService,
      zipArchiveService: services.dataManagementService.zipArchiveService
    )
    let messageManager = MessageManager(
      p2pChatManager: services.messengerService.p2pChatManager,
      appSettingsDataManager: services.messengerService.appSettingsDataManager,
      messengeDataManager: services.messengerService.messengeDataManager
    )
    let settingsManager = SettingsManager(
      appSettingsDataManager: services.messengerService.appSettingsDataManager,
      systemService: services.userInterfaceAndExperienceService.systemService,
      notificationService: services.userInterfaceAndExperienceService.notificationService
    )
    let toxManager = ToxManager(
      p2pChatManager: services.messengerService.p2pChatManager,
      appSettingsDataManager: services.messengerService.appSettingsDataManager,
      contactsDataManager: services.messengerService.contactsDataManager
    )
    let interfaceManager = InterfaceManager()
    
    switch accessType {
    case .demo:
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
    case .fake:
      return MessengerListScreenModuleFakeInteractor(
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
    case .main:
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
