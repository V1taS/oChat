//
//  MessengerListScreenModuleInteractor.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle
import AVFoundation

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
  ///   - return: Завершение, которое вызывается после завершения операции удаления
  func removeContactModels(_ contactModel: ContactModel) async -> Bool
  
  /// Получает адрес глубокой ссылки.
  /// - Parameter return: Результат в виде строки или nil, если адрес не найден.
  func getDeepLinkAdress() async -> String?
  
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
  ///   - return: Message ID
  func sendMessage(
    toxPublicKey: String,
    messengerRequest: MessengerNetworkRequestModel?
  ) async -> Int32?
  
  /// Запрос на переписку по указанному адресу.
  /// - Parameters:
  ///   - senderAddress: Адрес контакта
  ///   - messengerRequest: Данные запроса в виде `MessengerNetworkRequest`, содержащие информацию для начала переписки.
  ///   - return: Возвращает контакт ИД
  func initialChat(
    senderAddress: String,
    messengerRequest: MessengerNetworkRequestModel?
  ) async -> Int32?
  
  /// Получает адрес onion-сервиса.
  /// - Returns: Адрес сервиса или ошибка.
  func getToxAddress() async -> String?
  
  /// Метод для получения публичного ключа.
  /// - Returns: Публичный ключ в виде строки в шестнадцатеричном формате.
  func getToxPublicKey() async -> String?
  
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
  ///   - return: Возвращает результат выполнения в виде:
  func confirmFriendRequest(with publicToxKey: String) async -> String?
  
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
  
  /// Запуск TOX сервисы
  func stratTOXService() async
  
  /// Установить красную точку на таб баре
  func setRedDotToTabBar(value: String?)
  
  /// Метод для установки статуса "печатает" для друга.
  /// - Parameters:
  ///   - isTyping: Статус "печатает" (true, если пользователь печатает).
  ///   - toxPublicKey: Публичный ключ друга
  ///   - return: Результат успешного выполнения или ошибки.
  func setUserIsTyping(_ isTyping: Bool, to toxPublicKey: String) async -> Result<Void, Error>
  
  /// Метод для установки статуса пользователя.
  func setSelfStatus(isOnline: Bool) async
  
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
  func requestNotification() async -> Bool
  
  /// Метод для проверки, включены ли уведомления
  /// - Parameter enabled: Булево значение, указывающее, было ли включено уведомление
  func isNotificationsEnabled() async -> Bool
  
  /// Метод для отправки push-уведомлений
  func sendPushNotification(contact: ContactModel) async
  
  /// Запускает таймер для периодического вызова getFriendsStatus каждые 2 секунды.
  func startPeriodicFriendStatusCheck(completion: (() -> Void)?) async
  
  /// Очищает все временные ИДишники
  func clearAllMessengeTempID(completion: (() -> Void)?)
  
  /// Метод для разархивирования файлов
  func receiveAndUnzipFile(
    zipFileURL: URL,
    password: String,
    completion: @escaping (Result<(
      model: MessengerNetworkRequestModel,
      recordingDTO: MessengeRecordingDTO?,
      files: [URL]
    ), Error>) -> Void
  )
  
  /// Отправить файл с сообщением
  func sendFile(
    toxPublicKey: String,
    recipientPublicKey: String,
    recordModel: MessengeRecordingModel?,
    messengerRequest: MessengerNetworkRequestModel,
    files: [URL]
  ) async
  
  /// Делаем маленькое изображение
  func resizeThumbnailImageWithFrame(data: Data) -> Data?
  
  /// Получить объект
  /// - Parameter fileURL: Путь к файлу
  /// - Returns: Путь до файла `URL`
  func readObjectWith(fileURL: URL) -> Data?
  
  /// Очищает временную директорию.
  func clearTemporaryDirectory()
  
  /// Сохраняет объект по указанному временному URL и возвращает новый URL сохраненного объекта.
  /// - Parameter tempURL: Временный URL, по которому сохраняется объект.
  /// - Returns: Новый URL сохраненного объекта или nil в случае ошибки.
  func saveObjectWith(tempURL: URL) -> URL?
  
  /// Сохранить объект
  /// - Parameters:
  ///  - fileName: Название файла
  ///  - fileExtension: Расширение файла `.txt`
  ///  - data: Файл для записи
  /// - Returns: Путь до файла `URL`
  func saveObjectWith(
    fileName: String,
    fileExtension: String,
    data: Data
  ) -> URL?
  
  /// Сохранить объект в кеш
  /// - Parameters:
  ///  - fileName: Название файла
  ///  - fileExtension: Расширение файла `.txt`
  ///  - data: Файл для записи
  /// - Returns: Путь до файла `URL`
  func saveObjectToCachesWith(
    fileName: String,
    fileExtension: String,
    data: Data
  ) -> URL?
  
  /// Получить имя файла по URL
  func getFileName(from url: URL) -> String?
  
  /// Получить имя файла по URL без расширения
  func getFileNameWithoutExtension(from url: URL) -> String
  
  /// Получить кадр первой секунлы из видео
  func getFirstFrame(from url: URL) -> Data?
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
  private let dataManagementService: IDataManagerService
  
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
    dataManagementService = services.dataManagementService.dataManagerService
  }
}

// MARK: - MessengerListScreenModuleInteractorInput

extension MessengerListScreenModuleInteractor: MessengerListScreenModuleInteractorInput {
  func getFileNameWithoutExtension(from url: URL) -> String {
    dataManagementService.getFileNameWithoutExtension(from: url)
  }
  
  func getFileName(from url: URL) -> String? {
    dataManagementService.getFileName(from: url)
  }
  
  func saveObjectToCachesWith(
    fileName: String,
    fileExtension: String,
    data: Data
  ) -> URL? {
    dataManagementService.saveObjectToCachesWith(fileName: fileName, fileExtension: fileExtension, data: data)
  }
  
  func saveObjectWith(
    fileName: String,
    fileExtension: String,
    data: Data
  ) -> URL? {
    dataManagementService.saveObjectWith(fileName: fileName, fileExtension: fileExtension, data: data)
  }
  
  func readObjectWith(fileURL: URL) -> Data? {
    dataManagementService.readObjectWith(fileURL: fileURL)
  }
  
  func clearTemporaryDirectory() {
    dataManagementService.clearTemporaryDirectory()
  }
  
  func saveObjectWith(tempURL: URL) -> URL? {
    dataManagementService.saveObjectWith(tempURL: tempURL)
  }
  
  func getFirstFrame(from url: URL) -> Data? {
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTime(seconds: 1, preferredTimescale: 600)
    do {
      let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
      let uiImage = UIImage(cgImage: cgImage)
      if let imageData = uiImage.jpegData(compressionQuality: 1.0) {
        return imageData
      }
    } catch {
      print("Error extracting image from video: \(error.localizedDescription)")
    }
    return nil
  }
  
  func resizeThumbnailImageWithFrame(data: Data) -> Data? {
    guard let originalImage = UIImage(data: data) else { return nil }
    
    let targetSize = CGSize(width: 200, height: 200)
    
    let widthRatio = targetSize.width / originalImage.size.width
    let heightRatio = targetSize.height / originalImage.size.height
    let scaleFactor = max(widthRatio, heightRatio)
    
    let scaledImageSize = CGSize(
      width: originalImage.size.width * scaleFactor,
      height: originalImage.size.height * scaleFactor
    )
    
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    let framedImage = renderer.image { context in
      let origin = CGPoint(
        x: (targetSize.width - scaledImageSize.width) / 2,
        y: (targetSize.height - scaledImageSize.height) / 2
      )
      originalImage.draw(in: CGRect(origin: origin, size: scaledImageSize))
    }
    
    return framedImage.pngData()
  }
  
  func receiveAndUnzipFile(
    zipFileURL: URL,
    password: String,
    completion: @escaping (Result<(
      model: MessengerNetworkRequestModel,
      recordingDTO: MessengeRecordingDTO?,
      files: [URL]
    ), Error>) -> Void
  ) {
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      // Для получения директории Documents
      guard let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
        print("Ошибка: не удалось получить путь к директории Documents")
        return
      }
      let destinationURL = documentDirectory.appendingPathComponent(UUID().uuidString)
      
      var model: MessengerNetworkRequestModel?
      var recordingModel: MessengeRecordingDTO?
      var fileURLs: [URL] = []
      
      try? zipArchiveService.unzipFile(
        atPath: zipFileURL,
        toDestination: destinationURL,
        overwrite: true,
        password: password,
        progress: nil
      ) { [weak self] unzippedFile in
        guard let self else { return }
        print("Unzipped file: \(unzippedFile)")
        
        if unzippedFile.pathExtension == "model" {
          if let modelData = FileManager.default.contents(atPath: unzippedFile.path()) {
            let decoder = JSONDecoder()
            guard let dto = try? decoder.decode(MessengerNetworkRequestDTO.self, from: modelData) else {
              DispatchQueue.main.async {
                completion(.failure(URLError(.unknown)))
              }
              return
            }
            model = dto.mapToModel()
          } else {
            print("Не удалось прочитать данные из файла")
          }
        } else if unzippedFile.pathExtension == "record" {
          if let modelData = FileManager.default.contents(atPath: unzippedFile.path()) {
            let decoder = JSONDecoder()
            guard let model = try? decoder.decode(MessengeRecordingDTO.self, from: modelData) else {
              DispatchQueue.main.async {
                completion(.failure(URLError(.unknown)))
              }
              return
            }
            recordingModel = model
          } else {
            print("Не удалось прочитать данные из файла")
          }
        } else {
          fileURLs.append(unzippedFile)
        }
      }
      
      guard let model else {
        DispatchQueue.main.async {
          completion(.failure(URLError(.unknown)))
        }
        return
      }
      
      DispatchQueue.main.async {
        completion(.success((model, recordingModel, fileURLs)))
      }
    }
  }
  
  func startPeriodicFriendStatusCheck(completion: (() -> Void)?) async {
    await p2pChatManager.startPeriodicFriendStatusCheck { [weak self] friendStatus in
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
  
  func sendPushNotification(contact: ContactModel) async {
    guard let pushNotificationToken = contact.pushNotificationToken else {
      DispatchQueue.main.async { [weak self] in
        self?.notificationService.showNotification(.negative(title: "Нет токена для отправки уведомления"))
      }
      return
    }
    
    let myToxAddress = await p2pChatManager.getToxAddress()
    guard let myToxAddress else {
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
  
  func requestNotification() async -> Bool {
    await permissionService.requestNotification()
  }
  
  func isNotificationsEnabled() async -> Bool {
    await permissionService.isNotificationsEnabled()
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
  
  func setSelfStatus(isOnline: Bool) async {
    await p2pChatManager.setSelfStatus(isOnline: isOnline)
  }
  
  func setUserIsTyping(_ isTyping: Bool, to toxPublicKey: String) async -> Result<Void, Error> {
    await p2pChatManager.setUserIsTyping(isTyping, to: toxPublicKey)
  }
  
  func setRedDotToTabBar(value: String?) {
    guard let tabBarController = UIApplication.currentWindow?.rootViewController as? UITabBarController,
          (tabBarController.tabBar.items?.count ?? .zero) > .zero else {
      return
    }
    
    tabBarController.tabBar.items?[.zero].badgeValue = value
    tabBarController.tabBar.items?[.zero].badgeColor = SKStyleAsset.constantRuby.color
  }
  
  func stratTOXService() async {
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      modelHandlerService.getMessengerModel { [weak self] messengerModel in
        guard let self else { return }
        let toxStateAsString = messengerModel.toxStateAsString
        Task { [weak self] in
          guard let self else { return }
          do {
            await try? self.p2pChatManager.start(saveDataString: toxStateAsString)
            
            if toxStateAsString == nil {
              let stateAsString = await self.p2pChatManager.toxStateAsString()
              modelSettingsManager.setToxStateAsString(stateAsString, completion: nil)
            }
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
  
  func confirmFriendRequest(with publicToxKey: String) async -> String? {
    await p2pChatManager.confirmFriendRequest(with: publicToxKey)
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
    messengerRequest: MessengerNetworkRequestModel?
  ) async -> Int32? {
    guard let messengerRequest else {
      return nil
    }
    
    let dto = messengerRequest.mapToDTO()
    guard let json = createJSONString(from: dto) else {
      return nil
    }
    
    guard let contactID = await p2pChatManager.addFriend(address: senderAddress, message: json) else {
      return nil
    }
    await saveToxState()
    print("✅ Запрос отправлен")
    return contactID
  }
  
  func sendFile(
    toxPublicKey: String,
    recipientPublicKey: String,
    recordModel: MessengeRecordingModel?,
    messengerRequest: MessengerNetworkRequestModel,
    files: [URL]
  ) async {
    await p2pChatManager.sendFile(
      toxPublicKey: toxPublicKey,
      recipientPublicKey: recipientPublicKey,
      model: messengerRequest.mapToDTO(),
      recordModel: recordModel,
      files: files
    )
  }
  
  func sendMessage(
    toxPublicKey: String,
    messengerRequest: MessengerNetworkRequestModel?
  ) async -> Int32? {
    guard let messengerRequest else {
      return nil
    }
    let dto = messengerRequest.mapToDTO()
    guard let json = createJSONString(from: dto) else {
      return nil
    }
    
    let messageID = await try? p2pChatManager.sendMessage(to: toxPublicKey, message: json, messageType: .normal)
    guard let messageID else {
      return nil
    }
    await saveToxState()
    return messageID
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
  
  func getToxAddress() async -> String? {
    await p2pChatManager.getToxAddress()
  }
  
  func getToxPublicKey() async -> String? {
    await p2pChatManager.getToxPublicKey()
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
  
  func removeContactModels(_ contactModel: ContactModel) async -> Bool {
    modelHandlerService.removeContactModels(contactModel, completion: {})
    await saveToxState()
    return await p2pChatManager.deleteFriend(toxPublicKey: contactModel.toxPublicKey ?? "")
  }
  
  func saveContactModel(_ model: ContactModel, completion: (() -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      self?.modelHandlerService.saveContactModel(model, completion: { [weak self] in
        DispatchQueue.main.async {
          completion?()
          Task { [weak self] in
            await self?.saveToxState()
          }
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

  func getDeepLinkAdress() async -> String? {
    await deepLinkService.getMessengerAddress()
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
  
  func saveToxState() async {
    let stateAsString = await p2pChatManager.toxStateAsString()
    modelSettingsManager.setToxStateAsString(stateAsString, completion: {})
  }
}

// MARK: - Constants

private enum Constants {}
