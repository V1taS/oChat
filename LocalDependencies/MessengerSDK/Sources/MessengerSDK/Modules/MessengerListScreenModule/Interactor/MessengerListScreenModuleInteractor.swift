//
//  MessengerListScreenModuleInteractor.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol MessengerListScreenModuleInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol MessengerListScreenModuleInteractorInput {
  /// Расшифровывает данные, используя приватный ключ.
  /// - Parameters:
  ///   - encryptedData: Зашифрованные данные.
  ///   - privateKey: Приватный ключ.
  /// - Returns: Расшифрованные данные.
  /// - Throws: Ошибка расшифровки данных.
  func decrypt(_ encryptedData: String?, privateKey: String) -> String?
  
  /// Шифрует данные, используя публичный ключ.
  /// - Parameters:
  ///   - data: Данные для шифрования.
  ///   - publicKey: Публичный ключ.
  /// - Returns: Зашифрованные данные в виде строки.
  /// - Throws: Ошибка шифрования данных.
  func encrypt(_ data: String?, publicKey: String) -> String?
  
  /// Получает публичный ключ из приватного.
  /// - Parameter privateKey: Приватный ключ.
  /// - Returns: Публичный ключ в виде строки.
  /// - Throws: Ошибка генерации публичного ключа.
  func publicKey(from privateKey: String) -> String?
  
  /// Возвращает уникальный идентификатор устройства.
  /// - Returns: Строка, содержащая UUID устройства или "Unknown", если идентификатор не доступен.
  func getDeviceIdentifier() -> String
  
  /// Получает массив моделей контактов `ContactModel` асинхронно.
  /// - Parameter completion: Блок завершения, который вызывается с массивом `ContactModel` после завершения операции.
  func getContactModels(completion: @escaping ([ContactModel]) -> Void)
  
  /// Сохраняет `ContactModel` асинхронно.
  /// - Parameters:
  ///   - model: Модель `ContactModel`, которая будутет сохранена.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции сохранения.
  func saveContactModel(_ model: ContactModel, completion: (() -> Void)?)
  
  /// Удаляет модель контакта `ContactModel` асинхронно.
  /// - Parameters:
  ///   - contactModel: Модель `ContactModel`, которая будет удалена.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции удаления. Может быть `nil`.
  func removeContactModels(_ contactModel: ContactModel, completion: (() -> Void)?)
  
  /// Получает адрес глубокой ссылки.
  /// - Parameter completion: Блок выполнения с адресом в виде строки или nil, если адрес не найден.
  func getDeepLinkAdress(completion: ((_ adress: String?) -> Void)?)
  
  /// Удаляет URL глубокой ссылки.
  func deleteDeepLinkURL()
  
  /// Получает модель `MessengerModel` асинхронно.
  /// - Parameter completion: Блок завершения, который вызывается с `MessengerModel` после завершения операции.
  func getMessengerModel(completion: @escaping (MessengerModel) -> Void)
  
  /// Показать уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  func showNotification(_ type: NotificationServiceType)
  
  /// Отправляет сообщение на сервер.
  /// - Parameters:
  ///   - onionAddress: Адрес сервера в сети Onion.
  ///   - messengerRequest: Данные запроса в виде `MessengerNetworkRequest`, содержащие информацию для отправки.
  ///   - completion: Блок завершения, который возвращает `Result<Void, Error>` указывающий успешность операции.
  func sendMessage(
    onionAddress: String,
    messengerRequest: MessengerNetworkRequestModel?,
    completion: @escaping (Result<Void, Error>) -> Void
  )
  
  /// Инициирует переписку по указанному адресу.
  /// - Parameters:
  ///   - onionAddress: Адрес сервера в сети Onion.
  ///   - messengerRequest: Данные запроса в виде `MessengerNetworkRequest`, содержащие информацию для начала переписки.
  ///   - completion: Блок завершения, который возвращает `Result<Void, Error>` указывающий успешность операции.
  func initiateChat(
    onionAddress: String,
    messengerRequest: MessengerNetworkRequestModel?,
    completion: @escaping (Result<Void, Error>) -> Void
  )
  
  /// Получает адрес onion-сервиса.
  /// - Returns: Адрес сервиса или ошибка.
  func getOnionAddress(completion: ((Result<String, TorServiceError>) -> Void)?)
  
  /// Устанавливает, является ли контакт онлайн
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - status: Значение, указывающее, является ли контакт онлайн
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func setStatus(
    _ model: ContactModel,
    _ status: ContactModel.Status,
    completion: (() -> Void)?
  )
  
  /// Получить контакт по адресу onion
  func getContactModelsFrom(
    onionAddress: String,
    completion: ((ContactModel?) -> Void)?
  )
}

/// Интерактор
final class MessengerListScreenModuleInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MessengerListScreenModuleInteractorOutput?
  
  // MARK: - Private properties
  
  private let notificationService: INotificationService
  private var p2pChatManager: IP2PChatManager
  private let modelHandlerService: IMessengerModelHandlerService
  private let deepLinkService: IDeepLinkService
  private let cryptoService: ICryptoService
  private let systemService: ISystemService
  private let modelSettingsManager: IMessengerModelSettingsManager
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(services: IApplicationServices) {
    notificationService = services.userInterfaceAndExperienceService.notificationService
    p2pChatManager = services.messengerService.p2pChatManager
    modelHandlerService = services.messengerService.modelHandlerService
    deepLinkService = services.userInterfaceAndExperienceService.deepLinkService
    cryptoService = services.accessAndSecurityManagementService.cryptoService
    systemService = services.userInterfaceAndExperienceService.systemService
    modelSettingsManager = services.messengerService.modelSettingsManager
  }
}

// MARK: - MessengerListScreenModuleInteractorInput

extension MessengerListScreenModuleInteractor: MessengerListScreenModuleInteractorInput {
  func getContactModelsFrom(onionAddress: String, completion: ((ContactModel?) -> Void)?) {
    modelHandlerService.getContactModels { contactModels in
      if let contactIndex = contactModels.firstIndex(where: { $0.onionAddress == onionAddress }) {
        completion?(contactModels[contactIndex])
      } else {
        completion?(nil)
      }
    }
  }
  
  func initiateChat(
    onionAddress: String,
    messengerRequest: MessengerNetworkRequestModel?,
    completion: @escaping (Result<Void, any Error>
    ) -> Void) {
    p2pChatManager.initiateChat(
      onionAddress: onionAddress,
      messengerRequest: messengerRequest,
      completion: completion
    )
  }
  
  func sendMessage(
    onionAddress: String,
    messengerRequest: MessengerNetworkRequestModel?,
    completion: @escaping (Result<Void, any Error>
    ) -> Void) {
    p2pChatManager.sendMessage(
      onionAddress: onionAddress,
      messengerRequest: messengerRequest,
      completion: completion
    )
  }
  
  func encrypt(_ data: String?, publicKey: String) -> String? {
    cryptoService.encrypt(data, publicKey: publicKey)
  }
  
  func setStatus(_ model: ContactModel, _ status: SKAbstractions.ContactModel.Status, completion: (() -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.modelSettingsManager.setStatus(model, status, completion: completion)
    }
  }
  
  func getContactModels(completion: @escaping ([ContactModel]) -> Void) {
    DispatchQueue.global().async { [weak self] in
      self?.modelHandlerService.getContactModels(completion: completion)
    }
  }
  
  func decrypt(_ encryptedData: String?, privateKey: String) -> String? {
    cryptoService.decrypt(encryptedData, privateKey: privateKey)
  }
  
  func getOnionAddress(completion: ((Result<String, SKAbstractions.TorServiceError>) -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.p2pChatManager.getOnionAddress(completion: completion)
    }
  }
  
  func publicKey(from privateKey: String) -> String? {
    cryptoService.publicKey(from: privateKey)
  }
  
  func getDeviceIdentifier() -> String {
    systemService.getDeviceIdentifier()
  }
  
  func removeContactModels(_ contactModel: ContactModel, completion: (() -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.modelHandlerService.removeContactModels(contactModel, completion: completion)
    }
  }
  
  func saveContactModel(_ model: ContactModel, completion: (() -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.modelHandlerService.saveContactModel(model, completion: completion)
    }
  }
  
  func showNotification(_ type: SKAbstractions.NotificationServiceType) {
    notificationService.showNotification(type)
  }
  
  func getMessengerModel(completion: @escaping (SKAbstractions.MessengerModel) -> Void) {
    DispatchQueue.global().async { [weak self] in
      self?.modelHandlerService.getMessengerModel(completion: completion)
    }
  }
  
  func deleteDeepLinkURL() {
    DispatchQueue.global().async { [weak self] in
      self?.deepLinkService.deleteDeepLinkURL()
    }
  }
  
  func getDeepLinkAdress(completion: ((String?) -> Void)?) {
    deepLinkService.getMessengerAdress(completion: completion)
  }
}

// MARK: - Private

private extension MessengerListScreenModuleInteractor {}

// MARK: - Constants

private enum Constants {}
