//
//  MessengerListScreenModuleInteractor.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle

/// События которые отправляем из Interactor в Presenter
protocol MessengerListScreenModuleInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol MessengerListScreenModuleInteractorInput {
  /// Расшифровывает данные, используя приватный ключ.
  /// - Parameters:
  ///   - encryptedText: Зашифрованные данные.
  /// - Returns: Расшифрованные данные.
  /// - Throws: Ошибка расшифровки данных.
  func decrypt(_ encryptedText: String?, completion: ((String?) -> Void)?)
  
  /// Шифрует данные, используя публичный ключ.
  /// - Parameters:
  ///   - text: Данные для шифрования.
  ///   - publicKey: Публичный ключ.
  /// - Returns: Зашифрованные данные в виде строки.
  /// - Throws: Ошибка шифрования данных.
  func encrypt(_ text: String?, publicKey: String) -> String?
  
  /// Расшифровывает данные, используя приватный ключ.
  /// - Parameters:
  ///   - encryptedData: Зашифрованные данные.
  /// - privateKey: Приватный ключ.
  /// - Returns: Расшифрованные данные в виде объекта Data.
  /// - Throws: Ошибка расшифровки данных.
  func decrypt(_ encryptedData: Data?, completion: ((Data?) -> Void)?)
  
  /// Шифрует данные, используя публичный ключ.
  /// - Parameters:
  ///   - data: Данные для шифрования.
  ///   - publicKey: Публичный ключ.
  /// - Returns: Зашифрованные данные в виде объекта Data.
  /// - Throws: Ошибка шифрования данных.
  func encrypt(_ data: Data?, publicKey: String) -> Data?
  
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
  
  /// Получить контакт по адресу
  func getContactModelsFrom(
    toxAddress: String,
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
  
  /// Установить красную точку на таб баре
  func setRedDotToTabBar(value: String?)
  
  /// Метод для установки статуса "печатает" для друга.
  /// - Parameters:
  ///   - isTyping: Статус "печатает" (true, если пользователь печатает).
  ///   - toxPublicKey: Публичный ключ друга
  ///   - completion: Замыкание, вызываемое по завершении операции, с результатом успешного выполнения или ошибкой.
  func setUserIsTyping(
    _ isTyping: Bool,
    to toxPublicKey: String,
    completion: @escaping (Result<Void, Error>) -> Void
  )
  
  /// Метод для установки статуса пользователя.
  func setSelfStatus(isOnline: Bool)
  
  /// Переводит всех контактов в состояние Не Печатают
  func setAllContactsNoTyping(completion: (() -> Void)?)
  
  /// Получить токен для пушей
  func getPushNotificationToken(completion: ((String?) -> Void)?)
  
  /// Сохраняет токен для пуш сообщений
  /// - Parameters:
  ///   - token: Токен для пуш сообщений
  func saveMyPushNotificationToken(
    _ token: String,
    completion: (() -> Void)?
  )
  
  /// Запрос доступа к Уведомлениям
  /// - Parameter granted: Булево значение, указывающее, было ли предоставлено разрешение
  func requestNotification(completion: @escaping (_ granted: Bool) -> Void)
  
  /// Метод для проверки, включены ли уведомления
  /// - Parameter enabled: Булево значение, указывающее, было ли включено уведомление
  func isNotificationsEnabled(completion: @escaping (_ enabled: Bool) -> Void)
  
  /// Метод для отправки push-уведомлений
  func sendPushNotification(contact: ContactModel)
  
  /// Запускает таймер для периодического вызова getFriendsStatus каждые 2 секунды.
  func startPeriodicFriendStatusCheck(completion: (() -> Void)?)
  
  /// Очищает все временные ИДишники
  func clearAllMessengeTempID(completion: (() -> Void)?)
  
  /// Метод для разархивирования файлов
  func receiveAndUnzipFile(
    zipFileURL: URL,
    completion: @escaping (Result<(model: Data, files: [URL]), Error>) -> Void
  )
  
  /// Отправить файл с сообщением
  func sendFile(
    toxPublicKey: String,
    messengerRequest: MessengerNetworkRequestModel,
    files: [URL]
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
  private let permissionService: IPermissionService
  private let pushNotificationService: IPushNotificationService
  private let zipArchiveService: IZipArchiveService
  private var cacheFriendStatus: [String : Bool] = [:]
  
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
    permissionService = services.accessAndSecurityManagementService.permissionService
    pushNotificationService = services.pushNotificationService
    zipArchiveService = services.dataManagementService.zipArchiveService
  }
}

// MARK: - MessengerListScreenModuleInteractorInput

extension MessengerListScreenModuleInteractor: MessengerListScreenModuleInteractorInput {
  func receiveAndUnzipFile(
    zipFileURL: URL,
    completion: @escaping (Result<(model: Data, files: [URL]), Error>) -> Void
  ) {
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      let tempDirectory = FileManager.default.temporaryDirectory
      let destinationURL = tempDirectory.appendingPathComponent(UUID().uuidString)
      
      do {
        try zipArchiveService.unzipFile(
          atPath: zipFileURL,
          toDestination: destinationURL,
          overwrite: true,
          password: nil,
          progress: nil
        ) { unzippedFile in
          print("Unzipped file: \(unzippedFile)")
        }
        
        var modelData: Data?
        var fileURLs: [URL] = []
        
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(
          at: destinationURL,
          includingPropertiesForKeys: nil,
          options: []
        )
        
        for file in contents {
          if file.pathExtension == "model" {
            modelData = try Data(contentsOf: file)
          } else {
            fileURLs.append(file)
          }
        }
        
        guard let model = modelData else {
          throw URLError(.unknown)
        }
        
        // Сохранение файлов в системное хранилище
        let secureStorageURL = try saveFilesToSecureStorage(fileURLs)
        
        DispatchQueue.main.async {
          completion(.success((model, secureStorageURL)))
        }
      } catch {
        DispatchQueue.main.async {
          completion(.failure(error))
        }
      }
    }
  }
  
  func startPeriodicFriendStatusCheck(completion: (() -> Void)?) {
    p2pChatManager.startPeriodicFriendStatusCheck { [weak self] friendStatus in
      guard let self else { return }
      if cacheFriendStatus != friendStatus {
        cacheFriendStatus = friendStatus
        for (publicKey, isOnline) in friendStatus {
          getContactModelsFrom(toxPublicKey: publicKey) { [weak self] contactModel in
            guard let self else { return }
            var updateContact = contactModel
            if updateContact?.status != .initialChat || updateContact?.status != .requestChat {
              updateContact?.status = isOnline ? .online : .offline
            }
            if !isOnline {
              updateContact?.isTyping = false
            }
            
            if let updateContact {
              modelHandlerService.saveContactModel(updateContact, completion: { [weak self] in
                DispatchQueue.main.async {
                  completion?()
                  print("Friend \(publicKey) is \(isOnline ? "🟢🟢🟢 online" : "🔴🔴🔴 offline")")
                }
              })
            }
          }
        }
      }
    }
  }
  
  func sendPushNotification(contact: ContactModel) {
    guard let pushNotificationToken = contact.pushNotificationToken else {
      DispatchQueue.main.async { [weak self] in
        self?.notificationService.showNotification(.negative(title: "Нет токена для отправки уведомления"))
      }
      return
    }
    
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      p2pChatManager.getToxAddress { [weak self] result in
        guard let self,
              let myToxAddress = try? result.get() else {
          return
        }
        
        let mame: String = myToxAddress.formatString(minTextLength: 10)
        pushNotificationService.sendPushNotification(
          title: "Вас зовут в чат!",
          body: "Ваш контакт \(mame) хочет с вами пообщаться. Пожалуйста, зайдите в чат.",
          customData: ["toxAddress": contact.toxAddress],
          deviceToken: pushNotificationToken
        )
      }
    }
  }
  
  func requestNotification(completion: @escaping (Bool) -> Void) {
    permissionService.requestNotification(completion: completion)
  }
  
  func isNotificationsEnabled(completion: @escaping (Bool) -> Void) {
    permissionService.isNotificationsEnabled(completion: completion)
  }
  
  func saveMyPushNotificationToken(_ token: String, completion: (() -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.modelSettingsManager.saveMyPushNotificationToken(token) {
        DispatchQueue.main.async {
          completion?()
        }
      }
    }
  }
  
  func getPushNotificationToken(completion: ((String?) -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.modelHandlerService.getMessengerModel { messengerModel in
        DispatchQueue.main.async {
          completion?(messengerModel.pushNotificationToken)
        }
      }
    }
  }
  
  func clearAllMessengeTempID(completion: (() -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.modelSettingsManager.clearAllMessengeTempID(completion: {
        DispatchQueue.main.async {
          completion?()
        }
      })
    }
  }
  
  func setAllContactsNoTyping(completion: (() -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.modelSettingsManager.setAllContactsNoTyping(completion: {
        DispatchQueue.main.async {
          completion?()
        }
      })
    }
  }
  
  func setSelfStatus(isOnline: Bool) {
    DispatchQueue.global().async { [weak self] in
      self?.p2pChatManager.setSelfStatus(isOnline: isOnline)
    }
  }
  
  func setUserIsTyping(
    _ isTyping: Bool,
    to toxPublicKey: String,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    DispatchQueue.global().async { [weak self] in
      self?.p2pChatManager.setUserIsTyping(isTyping, to: toxPublicKey) { result in
        DispatchQueue.main.async { [weak self] in
          switch result {
          case .success:
            completion(.success(()))
          case let .failure(error):
            completion(.failure(error))
          }
        }
      }
    }
  }
  
  func setRedDotToTabBar(value: String?) {
    guard let tabBarController = UIApplication.currentWindow?.rootViewController as? UITabBarController,
          (tabBarController.tabBar.items?.count ?? .zero) > .zero else {
      return
    }
    
    tabBarController.tabBar.items?[.zero].badgeValue = value
    tabBarController.tabBar.items?[.zero].badgeColor = SKStyleAsset.constantRuby.color
  }
  
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
  
  func getContactModelsFrom(toxAddress: String, completion: ((ContactModel?) -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.modelHandlerService.getContactModels { contactModels in
        DispatchQueue.main.async { [weak self] in
          if let contactIndex = contactModels.firstIndex(where: { $0.toxAddress == toxAddress }) {
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
  
  func sendFile(
    toxPublicKey: String,
    messengerRequest: MessengerNetworkRequestModel,
    files: [URL]
  ) {
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      p2pChatManager.sendFile(
        toxPublicKey: toxPublicKey,
        model: messengerRequest.mapToDTO(),
        files: files
      )
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
  
  func getContactModels(completion: @escaping ([ContactModel]) -> Void) {
    DispatchQueue.global().async { [weak self] in
      self?.modelHandlerService.getContactModels(completion: { contactModel in
        DispatchQueue.main.async {
          completion(contactModel)
        }
      })
    }
  }
  
  func decrypt(_ encryptedData: Data?, completion: ((Data?) -> Void)?) {
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      guard let self else { return }
      let data = cryptoService.decrypt(
        encryptedData,
        privateKey: systemService.getDeviceIdentifier()
      )
      
      DispatchQueue.main.async {
        completion?(data)
      }
    }
  }
  
  func encrypt(_ data: Data?, publicKey: String) -> Data? {
    cryptoService.encrypt(data, publicKey: publicKey)
  }
  
  func encrypt(_ text: String?, publicKey: String) -> String? {
    cryptoService.encrypt(text, publicKey: publicKey)
  }
  
  func decrypt(_ encryptedText: String?, completion: ((String?) -> Void)?) {
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      guard let self else { return }
      let messenge = cryptoService.decrypt(
        encryptedText,
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
      self?.p2pChatManager.deleteFriend(
        toxPublicKey: contactModel.toxPublicKey ?? "",
        completion: { [weak self] _ in
          guard let self else { return }
          modelHandlerService.removeContactModels(contactModel, completion: {
            DispatchQueue.main.async {
              completion?()
            }
          })
          saveToxState()
        }
      )
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
  
  func saveFilesToSecureStorage(_ files: [URL]) throws -> [URL] {
    let fileManager = FileManager.default
    var savedFiles: [URL] = []
    
    // Получаем URL для директории Application Support
    guard let applicationSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      throw NSError(
        domain: "ToxFileReceiver",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Не удалось получить директорию Application Support"]
      )
    }
    
    for file in files {
      let secureStorageURL = applicationSupportDirectory.appendingPathComponent(
        UUID().uuidString
      ).appendingPathExtension(file.pathExtension)
      do {
        try fileManager.moveItem(at: file, to: secureStorageURL)
        savedFiles.append(secureStorageURL)
      } catch {
        throw NSError(
          domain: "ToxFileReceiver",
          code: 2,
          userInfo: [NSLocalizedDescriptionKey: "Не удалось переместить файл: \(error.localizedDescription)"]
        )
      }
    }
    return savedFiles
  }
}

// MARK: - Constants

private enum Constants {}
