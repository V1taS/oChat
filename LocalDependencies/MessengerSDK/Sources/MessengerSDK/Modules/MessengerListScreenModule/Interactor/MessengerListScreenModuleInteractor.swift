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
  /// - Returns: Расшифрованные данные.
  /// - Throws: Ошибка расшифровки данных.
  func decrypt(_ encryptedData: String?, completion: ((String?) -> Void)?)
  
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
  
  /// Извлекает публичный ключ из адреса Tox.
  /// - Параметр address: Адрес Tox в виде строки (76 символов).
  /// - Возвращаемое значение: Строка с публичным ключом (64 символа) или `nil` при ошибке.
  func getToxPublicKey(from address: String) -> String?
  
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
  ///   - toxPublicKey: Публичный ключ контакта, который находится в контактах
  ///   - messengerRequest: Данные запроса в виде `MessengerNetworkRequest`, содержащие информацию для отправки.
  ///   - completion: Блок завершения, который возвращает `Result<Void, Error>` указывающий успешность операции.
  func sendMessage(
    toxPublicKey: String,
    messengerRequest: MessengerNetworkRequestModel?,
    completion: @escaping (Result<Int32, Error>) -> Void
  )
  
  /// Запрос на переписку по указанному адресу.
  /// - Parameters:
  ///   - senderAddress: Адрес контакта
  ///   - messengerRequest: Данные запроса в виде `MessengerNetworkRequest`, содержащие информацию для начала переписки.
  ///   - completion: Блок завершения, который возвращает `Result<Void, Error>` указывающий успешность операции.
  func initialChat(
    senderAddress: String,
    messengerRequest: MessengerNetworkRequestModel?,
    completion: @escaping (Result<Int32?, Error>) -> Void
  )
  
  /// Получает адрес onion-сервиса.
  /// - Returns: Адрес сервиса или ошибка.
  func getToxAddress(completion: ((Result<String, TorServiceError>) -> Void)?)
  
  /// Метод для получения публичного ключа.
  /// - Returns: Публичный ключ в виде строки в шестнадцатеричном формате.
  func getToxPublicKey(completion: @escaping (String?) -> Void)
  
  /// Получить контакт по адресу onion
  func getContactModelsFrom(
    onionAddress: String,
    completion: ((ContactModel?) -> Void)?
  )
  
  /// Получить контакт по публичному ключу
  func getContactModelsFrom(
    toxPublicKey: String,
    completion: ((ContactModel?) -> Void)?
  )
  
  /// Используя метод confirmFriendRequest, вы подтверждаете запрос на добавление в друзья, зная публичный ключ отправителя.
  /// Этот метод принимает публичный ключ друга и добавляет его в список друзей без отправки дополнительного сообщения.
  /// - Parameters:
  ///   - publicKey: Строка, представляющая публичный ключ друга. Этот ключ используется для идентификации пользователя в сети Tox.
  ///   - completion: Замыкание, вызываемое после завершения операции. Возвращает результат выполнения в виде:
  func confirmFriendRequest(
    with publicToxKey: String,
    completion: @escaping (Result<String, Error>) -> Void
  )
  
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
  
  /// Переводит всех контактов в состояние оффлайн.
  /// - Parameter completion: Опциональный блок завершения, вызываемый после того, как все контакты будут переведены в оффлайн.
  func setAllContactsIsOffline(completion: (() -> Void)?)
  
  /// Проверяем установлен ли пароль на телефоне, это необходимо для шифрования данных
  func passcodeNotSetInSystemIOSheck()
  
  /// Запуск TOR + TOX сервисы
  func stratTORxService()
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
  func stratTORxService() {
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      modelHandlerService.getMessengerModel { [weak self] messengerModel in
        guard let self else { return }
        let toxStateAsString = messengerModel.toxStateAsString
        
        p2pChatManager.start(
          saveDataString: toxStateAsString) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
              if toxStateAsString == nil {
                p2pChatManager.toxStateAsString { [weak self] stateAsString in
                  guard let self else { return }
                  modelSettingsManager
                    .setToxStateAsString(stateAsString, completion: {})
                }
              }
            case .failure:
              break
            }
          }
      }
    }
  }
  
  func passcodeNotSetInSystemIOSheck() {
    DispatchQueue.global().async { [weak self] in
      self?.systemService.checkIfPasscodeIsSet { [weak self] result in
        guard let self else { return }
        if case let .failure(error) = result, error == .passcodeNotSet {
          DispatchQueue.main.async { [weak self] in
            self?.notificationService.showNotification(
              .negative(
                title: MessengerSDKStrings.MessengerListScreenModuleLocalization
                  .stateNotificationPasscodeNotSetTitle
              )
            )
          }
        }
      }
    }
  }
  
  func setAllContactsIsOffline(completion: (() -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.modelSettingsManager.setAllContactsIsOffline {
        DispatchQueue.main.async {
          completion?()
        }
      }
    }
  }
  
  func setStatus(_ model: ContactModel, _ status: ContactModel.Status, completion: (() -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.modelSettingsManager.setStatus(model, status, completion: {
        DispatchQueue.main.async {
          completion?()
        }
      })
    }
  }
  
  func confirmFriendRequest(
    with publicToxKey: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    DispatchQueue.global().async { [weak self] in
      self?.p2pChatManager.confirmFriendRequest(with: publicToxKey) { [weak self] result in
        DispatchQueue.main.async {
          completion(result)
        }
      }
    }
  }
  
  func getContactModelsFrom(
    toxPublicKey: String,
    completion: ((ContactModel?) -> Void)?
  ) {
    DispatchQueue.global().async { [weak self] in
      self?.modelHandlerService.getContactModels { contactModels in
        DispatchQueue.main.async { [weak self] in
          if let contactIndex = contactModels.firstIndex(where: { $0.toxPublicKey == toxPublicKey }) {
            completion?(contactModels[contactIndex])
          } else {
            completion?(nil)
          }
        }
      }
    }
  }
  
  func getContactModelsFrom(onionAddress: String, completion: ((ContactModel?) -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.modelHandlerService.getContactModels { contactModels in
        DispatchQueue.main.async { [weak self] in
          if let contactIndex = contactModels.firstIndex(where: { $0.toxAddress == onionAddress }) {
            completion?(contactModels[contactIndex])
          } else {
            completion?(nil)
          }
        }
      }
    }
  }
  
  func initialChat(
    senderAddress: String,
    messengerRequest: MessengerNetworkRequestModel?,
    completion: @escaping (Result<Int32?, Error>) -> Void) {
      guard let messengerRequest else {
        return
      }
      
      DispatchQueue.global().async { [weak self] in
        let dto = messengerRequest.mapToDTO()
        guard let json = self?.createJSONString(from: dto) else {
          return
        }
        
        self?.p2pChatManager.addFriend(address: senderAddress, message: json, completion: { contactID in
          DispatchQueue.main.async { [weak self] in
            print("✅ Запрос отправлен")
            completion(.success(contactID))
            self?.saveToxState()
          }
        })
      }
    }
  
  func sendMessage(
    toxPublicKey: String,
    messengerRequest: MessengerNetworkRequestModel?,
    completion: @escaping (Result<Int32, Error>) -> Void) {
      guard let messengerRequest else {
        return
      }
      
      DispatchQueue.global().async { [weak self] in
        let dto = messengerRequest.mapToDTO()
        guard let json = self?.createJSONString(from: dto) else {
          return
        }
        
        self?.p2pChatManager.sendMessage(
          to: toxPublicKey,
          message: json,
          messageType: .normal) { [weak self] result in
            DispatchQueue.main.async {
              switch result {
              case let .success(messageId):
                completion(.success(messageId))
              case let .failure(error):
                completion(.failure(error))
              }
              self?.saveToxState()
            }
          }
      }
    }
  
  func encrypt(_ data: String?, publicKey: String) -> String? {
    cryptoService.encrypt(data, publicKey: publicKey)
  }
  
  func getContactModels(completion: @escaping ([ContactModel]) -> Void) {
    DispatchQueue.global().async { [weak self] in
      self?.modelHandlerService.getContactModels(completion: { contactModel in
        DispatchQueue.main.async {
          completion(contactModel)
        }
      })
    }
  }
  
  func decrypt(_ encryptedData: String?, completion: ((String?) -> Void)?) {
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      guard let self else { return }
      let messenge = cryptoService.decrypt(
        encryptedData,
        privateKey: systemService.getDeviceIdentifier()
      )
      
      DispatchQueue.main.async {
        completion?(messenge)
      }
    }
  }
  
  func getToxAddress(completion: ((Result<String, TorServiceError>) -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.p2pChatManager.getToxAddress(completion: { result in
        DispatchQueue.main.async {
          switch result {
          case let .success(toxAddress):
            completion?(.success(toxAddress))
          case .failure(_):
            completion?(.failure(.onionAddressForTorHiddenServiceCouldNotBeLoaded))
          }
        }
      })
    }
  }
  
  func getToxPublicKey(completion: @escaping (String?) -> Void) {
    DispatchQueue.global().async { [weak self] in
      self?.p2pChatManager.getToxPublicKey(completion: { toxPublicKey in
        DispatchQueue.main.async {
          completion(toxPublicKey)
        }
      })
    }
  }
  
  func publicKey(from privateKey: String) -> String? {
    cryptoService.publicKey(from: privateKey)
  }
  
  func getToxPublicKey(from address: String) -> String? {
    p2pChatManager.getToxPublicKey(from: address)
  }
  
  func getDeviceIdentifier() -> String {
    systemService.getDeviceIdentifier()
  }
  
  func removeContactModels(_ contactModel: ContactModel, completion: (() -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      if let toxPublicKey = contactModel.toxPublicKey {
        self?.p2pChatManager.deleteFriend(toxPublicKey: toxPublicKey, completion: {_ in})
      }
      self?.modelHandlerService.removeContactModels(contactModel, completion: {
        DispatchQueue.main.async {
          completion?()
        }
      })
      self?.saveToxState()
    }
  }
  
  func saveContactModel(_ model: ContactModel, completion: (() -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.modelHandlerService.saveContactModel(model, completion: { [weak self] in
        DispatchQueue.main.async {
          completion?()
          self?.saveToxState()
        }
      })
    }
  }
  
  func showNotification(_ type: SKAbstractions.NotificationServiceType) {
    DispatchQueue.main.async { [weak self] in
      self?.notificationService.showNotification(type)
    }
  }
  
  func getMessengerModel(completion: @escaping (MessengerModel) -> Void) {
    DispatchQueue.global().async { [weak self] in
      self?.modelHandlerService.getMessengerModel(completion: { messengerModel in
        DispatchQueue.main.async {
          completion(messengerModel)
        }
      })
    }
  }
  
  func deleteDeepLinkURL() {
    DispatchQueue.global().async { [weak self] in
      self?.deepLinkService.deleteDeepLinkURL()
    }
  }
  
  func getDeepLinkAdress(completion: ((String?) -> Void)?) {
    deepLinkService.getMessengerAdress { adress in
      DispatchQueue.main.async {
        completion?(adress)
      }
    }
  }
}

// MARK: - Private

private extension MessengerListScreenModuleInteractor {
  func createJSONString(from dto: MessengerNetworkRequestDTO) -> String? {
    let encoder = JSONEncoder()
    
    do {
      let jsonData = try encoder.encode(dto)
      guard let jsonString = String(data: jsonData, encoding: .utf8) else {
        print("Ошибка преобразования данных JSON в строку.")
        return nil
      }
      return jsonString
    } catch {
      print("Ошибка кодирования модели в JSON: \(error)")
      return nil
    }
  }
  
  func saveToxState() {
    p2pChatManager.toxStateAsString { [weak self] stateAsString in
      self?.modelSettingsManager.setToxStateAsString(stateAsString, completion: {})
    }
  }
}

// MARK: - Constants

private enum Constants {}
