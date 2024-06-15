//
//  ToxCore.swift
//
//
//  Created by Vitalii Sosin on 09.06.2024.
//

import Foundation
import ToxCoreCpp

/// Основной класс для работы с Tox.
public final class ToxCore {
  
  // MARK: - Public properties
  
  public static let shared = ToxCore()
  
  // MARK: - Private properties
  
  private var tox: UnsafeMutablePointer<Tox>?
  private let toxQueue = DispatchQueue(label: "com.SosinVitalii.toxQueue")
  private var timer: DispatchSourceTimer?
  private var toxNodesJsonString: String = ""
  
  // MARK: - Init
  
  private init() {}
}

// MARK: - Life cycle Tox

public extension ToxCore {
  /// Создаёт новый экземпляр Tox с заданными параметрами.
  /// - Parameters:
  ///   - options: Опции для настройки Tox.
  ///   - savedDataString: Сохранённые данные для восстановления состояния Tox, по умолчанию nil.
  ///   - toxNodesJsonString: JSON-строка с конфигурацией узлов Tox.
  ///   - completion: Завершающий блок с результатом операции: успех или ошибка.
  func createNewTox(
    with options: ToxOptions,
    savedDataString: String? = nil,
    toxNodesJsonString: String,
    completion: @escaping (Result<Void, ToxError>) -> Void
  ) {
    self.toxNodesJsonString = toxNodesJsonString
    toxQueue.async {
      var error: Tox_Err_New = TOX_ERR_NEW_OK
      
      // Преобразуем Swift опции в C-структуру
      var toxOptions = ToxOptions.convertToToxOptions(from: options)
      
      if let savedDataString = savedDataString,
         let data = Data(base64Encoded: savedDataString) {
        toxOptions.savedata_type = TOX_SAVEDATA_TYPE_TOX_SAVE
        data.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) in
          toxOptions.savedata_data = rawBufferPointer.baseAddress?.assumingMemoryBound(to: UInt8.self)
          toxOptions.savedata_length = data.count
        }
      } else {
        toxOptions.savedata_type = TOX_SAVEDATA_TYPE_NONE
      }
      
      self.tox = tox_new(&toxOptions, &error)
      if error != TOX_ERR_NEW_OK {
        let swiftError = ToxError(cError: error)
        completion(.failure(swiftError))
      } else {
        self.bootstrap { result in
          completion(result)
          if case .success = result {
            self.registerEventHandlers()
            self.startEventLoop()
          }
        }
      }
    }
  }
  
  /// Метод для остановки сервиса Tox и освобождения ресурсов.
  /// - Parameter completion: Замыкание, вызываемое после завершения операции.
  func stopTox(completion: @escaping (Result<Void, ToxError>) -> Void) {
    stopEventLoop()
    toxQueue.async {
      guard let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      tox_kill(tox)
      self.tox = nil
      completion(.success(()))
    }
  }
  
  /// Перезапускает экземпляр Tox с новыми опциями.
  /// - Parameters:
  ///   - options: Опции для настройки нового экземпляра Tox.
  ///   - toxNodesJsonString: JSON-строка, содержащая конфигурацию узлов Tox.
  ///   - completion: Завершающий блок, который возвращает результат операции: успех или ошибка.
  func restartTox(
    with options: ToxOptions,
    toxNodesJsonString: String,
    completion: @escaping (Result<Void, ToxError>) -> Void
  ) {
    stopTox { [weak self] stopResult in
      switch stopResult {
      case .success:
        self?.createNewTox(with: options, toxNodesJsonString: toxNodesJsonString) { createResult in
          completion(createResult)
        }
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
}

// MARK: - Callback

public extension ToxCore {
  /// Устанавливает обратный вызов для получения статуса подключения.
  /// - Parameter callback: Функция обратного вызова, которая будет вызвана при изменении статуса подключения.
  func setConnectionStatusCallback(callback: @escaping (ConnectionStatus) -> Void) {
    toxQueue.async {
      // Проверяем, инициализирован ли объект Tox
      guard let tox = self.tox else { return }
      
      // Создаем и сохраняем контекст с переданным замыканием
      let context = ConnectionStatusContext(callback: callback)
      globalConnectionStatusContext = context
      
      // Устанавливаем глобальный коллбек для обработки статуса соединения
      tox_callback_self_connection_status(tox, connectionStatusCallback)
    }
  }
  
  /// Вызывается, когда кто-то отправляет вам запрос на добавление в друзья
  /// Этот метод сохраняет контекст с замыканием для обработки запросов на добавление в друзья и устанавливает глобальный коллбек.
  /// - Parameter callback: Замыкание, которое вызывается при получении запроса на добавление в друзья. Замыкание принимает два параметра:
  ///     - publicKey: Строка, представляющая публичный ключ отправителя запроса.
  ///     - message: Строка, представляющая сообщение, прикрепленное к запросу.
  func setFriendRequestCallback(
    callback: @escaping (_ publicKey: String, _ message: String) -> Void
  ) {
    toxQueue.async {
      // Проверяем, инициализирован ли объект Tox.
      guard let tox = self.tox else { return }
      
      // Создаем и сохраняем контекст с переданным замыканием.
      let context = FriendRequestContext(callback: callback)
      globalConnectioFriendRequestContext = context
      
      // Устанавливаем глобальный коллбек для обработки запросов на добавление в друзья.
      tox_callback_friend_request(tox, friendRequestCallback)
    }
  }
  
  /// Метод для регистрации обратного вызова на получение сообщений.
  /// - Parameter callback: Замыкание, вызываемое при получении нового сообщения.
  ///     - friendId: Уникальный идентификатор друга, от которого пришло сообщение.
  ///     - message: Текст сообщения.
  func setMessageCallback(
    callback: @escaping (
      _ friendId: Int32,
      _ message: String
    ) -> Void) {
      toxQueue.async {
        guard let tox = self.tox else { return }
        
        // Сохраняем контекст
        let context = MessageContext(callback: callback)
        globalConnectionMessageContext = context
        
        // Устанавливаем глобальный коллбек
        tox_callback_friend_message(tox, messageCallback)
      }
    }
  
  /// Метод для регистрации обратного вызова на получение данных файла.
  /// - Parameter callback: Замыкание, вызываемое при получении части файла. Возвращает следующие параметры:
  ///     - friendId: Уникальный идентификатор друга, отправившего файл.
  ///     - fileId: Уникальный идентификатор файла.
  ///     - position: Позиция начала данных.
  ///     - data: Данные файла.
  func setFileChunkReceiveCallback(callback: @escaping (Int32, Int32, UInt64, Data) -> Void) {
    toxQueue.async {
      guard let tox = self.tox else { return }
      
      // Сохраняем контекст
      let context = FileChunkReceiveContext(callback: callback)
      globalConnectionFileChunkReceiveContext = context
      
      // Устанавливаем глобальный коллбек
      tox_callback_file_recv_chunk(tox, fileChunkReceiveCallback)
    }
  }
  
  /// Метод для регистрации обратного вызова на получение уведомлений о новом файле.
  /// - Parameter callback: Замыкание, вызываемое при получении нового файла. Возвращает следующие параметры:
  ///     - friendId: Уникальный идентификатор друга, отправившего файл.
  ///     - fileId: Уникальный идентификатор файла.
  ///     - fileName: Имя файла.
  ///     - fileSize: Размер файла в байтах.
  func setFileReceiveCallback(callback: @escaping (Int32, Int32, String, UInt64) -> Void) {
    toxQueue.async {
      guard let tox = self.tox else { return }
      
      // Сохраняем контекст
      let context = FileReceiveContext(callback: callback)
      globalConnectionFileReceiveContext = context
      
      // Устанавливаем глобальный коллбек
      tox_callback_file_recv(tox, fileReceiveCallback)
    }
  }
}

// MARK: - Data Tox

public extension ToxCore {
  /// Метод для сохранения состояния Tox в строку.
  /// - Returns: Строка, содержащая сохранённое состояние Tox в формате Base64, или nil, если произошла ошибка.
  func saveToxStateAsString() -> String? {
    guard let tox = self.tox else {
      // Логируем ошибку, если Tox не инициализирован
      print("Tox is not initialized.")
      return nil
    }
    
    // Определяем размер данных для сохранения
    let size = tox_get_savedata_size(tox)
    
    // Выделяем память для сохранения данных
    guard let cData = malloc(size) else {
      // Логируем ошибку, если не удалось выделить память
      print("Failed to allocate memory for saved data.")
      return nil
    }
    
    defer {
      // Освобождаем память после использования
      free(cData)
    }
    
    // Сохраняем данные в выделенную память
    tox_get_savedata(tox, cData.assumingMemoryBound(to: UInt8.self))
    
    // Преобразуем сохраненные данные в объект Data
    let data = Data(bytes: cData, count: size)
    
    // Преобразуем Data в строку в формате Base64
    let base64String = data.base64EncodedString()
    
    // Логируем успешное сохранение
    print("Saved data with length \(data.count).")
    
    return base64String
  }
  
  /// Метод для получения публичного ключа.
  /// - Returns: Публичный ключ в виде строки в шестнадцатеричном формате.
  func getPublicKey() -> String? {
    guard let tox = self.tox else {
      print("Tox is not initialized.")
      return nil
    }
    
    var cPublicKey = [UInt8](repeating: 0, count: Int(TOX_PUBLIC_KEY_SIZE))
    tox_self_get_public_key(tox, &cPublicKey)
    let publicKey = cPublicKey.map { String(format: "%02x", $0) }.joined()
    return publicKey
  }
  
  /// Метод для получения секретного ключа.
  /// - Returns: Секретный ключ в виде строки в шестнадцатеричном формате.
  func getSecretKey() -> String? {
    guard let tox = self.tox else {
      print("Tox is not initialized.")
      return nil
    }
    
    var cSecretKey = [UInt8](repeating: 0, count: Int(TOX_SECRET_KEY_SIZE))
    tox_self_get_secret_key(tox, &cSecretKey)
    let secretKey = cSecretKey.map { String(format: "%02x", $0) }.joined()
    return secretKey
  }
  
  /// Метод для установки значения nospam.
  /// - Parameter nospam: Значение nospam.
  func setNospam(_ nospam: UInt32) {
    guard let tox = self.tox else {
      print("Tox is not initialized.")
      return
    }
    
    tox_self_set_nospam(tox, nospam)
  }
  
  /// Метод для получения значения nospam.
  /// - Returns: Значение nospam.
  func getNospam() -> UInt32? {
    guard let tox = self.tox else {
      print("Tox is not initialized.")
      return nil
    }
    
    let nospam = tox_self_get_nospam(tox)
    return nospam
  }
  
  /// Генерирует новый адрес Tox и возвращает результат через завершение.
  /// - Parameter completion: Блок завершения, который возвращает результат генерации адреса.
  func generateToxAddress(completion: @escaping (Result<String, ToxError>) -> Void) {
    let CRYPTO_PUBLIC_KEY_SIZE = 32
    let TOX_NOSPAM_SIZE = 4
    let TOX_CHECKSUM_SIZE = 2
    let FRIEND_ADDRESS_SIZE = CRYPTO_PUBLIC_KEY_SIZE + TOX_NOSPAM_SIZE + TOX_CHECKSUM_SIZE
    
    toxQueue.async { [self] in
      guard let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      // Получаем публичный ключ
      var publicKey = [UInt8](repeating: 0, count: CRYPTO_PUBLIC_KEY_SIZE)
      tox_self_get_public_key(tox, &publicKey)
      
      // Получаем nospam-код
      let nospam = tox_self_get_nospam(tox)
      var nospamBytes = withUnsafeBytes(of: nospam.littleEndian, Array.init)
      
      // Создаем адрес
      var address = [UInt8](repeating: 0, count: FRIEND_ADDRESS_SIZE)
      address[..<CRYPTO_PUBLIC_KEY_SIZE] = publicKey[...]
      address[CRYPTO_PUBLIC_KEY_SIZE..<(CRYPTO_PUBLIC_KEY_SIZE + TOX_NOSPAM_SIZE)] = nospamBytes[...]
      
      // Вычисляем и добавляем контрольную сумму
      let checksum = addressChecksum(address: address, length: CRYPTO_PUBLIC_KEY_SIZE + TOX_NOSPAM_SIZE)
      var checksumBytes = withUnsafeBytes(of: checksum.littleEndian, Array.init)
      address[(CRYPTO_PUBLIC_KEY_SIZE + TOX_NOSPAM_SIZE)...] = checksumBytes[...]
      
      // Преобразуем адрес в шестнадцатеричную строку
      let addressHex = address.map { String(format: "%02x", $0) }.joined()
      
      completion(.success(addressHex.uppercased()))
    }
  }
}

// MARK: - User Tox

public extension ToxCore {
  /// Метод для установки статуса пользователя.
  /// - Parameter status: Статус пользователя (online, away, busy).
  func setSelfStatus(_ status: UserStatus) {
    guard let tox = self.tox else {
      print("Tox is not initialized.")
      return
    }
    
    let cStatus: TOX_USER_STATUS
    switch status {
    case .online:
      cStatus = TOX_USER_STATUS_NONE
    case .away:
      cStatus = TOX_USER_STATUS_AWAY
    case .busy:
      cStatus = TOX_USER_STATUS_BUSY
    }
    tox_self_set_status(tox, cStatus)
  }
  
  /// Метод для установки никнейма пользователя.
  /// - Parameters:
  ///   - name: Новый никнейм пользователя.
  ///   - completion: Замыкание, вызываемое по завершении операции, с результатом успешного выполнения или ошибкой.
  func setNickname(
    _ name: String,
    completion: @escaping (Result<Void, ToxError>) -> Void
  ) {
    toxQueue.async { [weak self] in
      guard let self = self, let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      // Проверяем валидность строки
      guard !name.isEmpty else {
        completion(.failure(.null))
        return
      }
      
      // Преобразуем строку в массив байтов
      guard let cName = name.cString(using: .utf8) else {
        completion(.failure(.unknown))
        return
      }
      let length = name.lengthOfBytes(using: .utf8)
      
      var cError: TOX_ERR_SET_INFO = TOX_ERR_SET_INFO_OK
      
      // Используем функцию tox_self_set_name для установки никнейма
      let result = tox_self_set_name(tox, cName, length, &cError)
      
      if result {
        completion(.success(()))
      } else {
        let error = ToxError(setInfoError: cError)
        completion(.failure(error))
      }
    }
  }
  
  /// Метод для получения имени пользователя.
  /// - Parameter completion: Замыкание, вызываемое по завершении операции, с результатом успешного выполнения или ошибкой.
  func getSelfName(completion: @escaping (Result<String, ToxError>) -> Void) {
    toxQueue.async { [weak self] in
      guard let self = self, let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      // Получаем размер имени пользователя
      let length = tox_self_get_name_size(tox)
      
      // Если длина равна нулю, имя не задано
      guard length > 0 else {
        completion(.failure(.emptyUserName))
        return
      }
      
      // Выделяем память для имени пользователя
      var cName = [UInt8](repeating: 0, count: Int(length))
      
      // Получаем имя пользователя
      tox_self_get_name(tox, &cName)
      
      // Преобразуем полученные байты в строку
      if let name = String(bytes: cName, encoding: .utf8) {
        completion(.success(name))
      } else {
        completion(.failure(.invalidStringEncoding))
      }
    }
  }
  
  /// Метод для получения имени друга по его номеру.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  ///   - completion: Замыкание, вызываемое по завершении операции, с результатом успешного выполнения или ошибкой.
  func getFriendName(friendNumber: Int32, completion: @escaping (Result<String, ToxError>) -> Void) {
    toxQueue.async { [weak self] in
      guard let self = self, let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      var cError: TOX_ERR_FRIEND_QUERY = TOX_ERR_FRIEND_QUERY_OK
      
      // Получаем размер имени друга
      let size = tox_friend_get_name_size(tox, UInt32(friendNumber), &cError)
      
      if cError != TOX_ERR_FRIEND_QUERY_OK {
        let error = ToxError(friendQueryError: cError)
        completion(.failure(error))
        return
      }
      
      // Если размер равен нулю, имя не задано
      guard size > 0 else {
        completion(.failure(.emptyFriendName))
        return
      }
      
      // Создаем массив для хранения имени друга
      var cName = [UInt8](repeating: 0, count: Int(size))
      
      // Получаем имя друга
      let result = tox_friend_get_name(tox, UInt32(friendNumber), &cName, &cError)
      
      if !result {
        let error = ToxError(friendQueryError: cError)
        completion(.failure(error))
        return
      }
      
      // Преобразуем байты в строку
      if let name = String(bytes: cName, encoding: .utf8) {
        completion(.success(name))
      } else {
        completion(.failure(.invalidStringEncoding))
      }
    }
  }
  
  /// Метод для установки статусного сообщения пользователя.
  /// - Parameters:
  ///   - statusMessage: Новое статусное сообщение пользователя.
  ///   - completion: Замыкание, вызываемое по завершении операции, с результатом успешного выполнения или ошибкой.
  func setUserStatusMessage(
    _ statusMessage: String,
    completion: @escaping (Result<Void, ToxError>) -> Void
  ) {
    toxQueue.async { [weak self] in
      guard let self = self, let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      // Проверка на пустое сообщение
      guard !statusMessage.isEmpty else {
        completion(.failure(.emptyStatusMessage))
        return
      }
      
      // Преобразуем сообщение в массив байтов
      guard let cStatusMessage = statusMessage.cString(using: .utf8) else {
        completion(.failure(.invalidStringEncoding))
        return
      }
      let length = statusMessage.lengthOfBytes(using: .utf8)
      
      var cError: TOX_ERR_SET_INFO = TOX_ERR_SET_INFO_OK
      
      // Используем функцию tox_self_set_status_message для установки статусного сообщения
      let result = tox_self_set_status_message(tox, cStatusMessage, length, &cError)
      
      if result {
        completion(.success(()))
      } else {
        let error = ToxError(setInfoError: cError)
        completion(.failure(error))
      }
    }
  }
  
  /// Метод для получения статусного сообщения пользователя.
  /// - Parameter completion: Замыкание, вызываемое по завершении операции, с результатом успешного выполнения или ошибкой.
  func getUserStatusMessage(completion: @escaping (Result<String, ToxError>) -> Void) {
    toxQueue.async { [weak self] in
      guard let self = self, let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      // Получаем размер статусного сообщения
      let length = tox_self_get_status_message_size(tox)
      
      // Если длина равна нулю, статусное сообщение не задано
      guard length > 0 else {
        completion(.failure(.emptyStatusMessage))
        return
      }
      
      // Создаем массив для хранения статусного сообщения
      var cBuffer = [UInt8](repeating: 0, count: Int(length))
      
      // Получаем статусное сообщение
      tox_self_get_status_message(tox, &cBuffer)
      
      // Преобразуем полученные байты в строку
      if let message = String(bytes: cBuffer, encoding: .utf8) {
        completion(.success(message))
      } else {
        completion(.failure(.invalidStringEncoding))
      }
    }
  }
  
  /// Метод для получения статусного сообщения друга по его номеру.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  ///   - completion: Замыкание, вызываемое по завершении операции, с результатом успешного выполнения или ошибкой.
  func getFriendStatusMessage(friendNumber: Int32, completion: @escaping (Result<String, ToxError>) -> Void) {
    toxQueue.async { [weak self] in
      guard let self = self, let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      var cError: TOX_ERR_FRIEND_QUERY = TOX_ERR_FRIEND_QUERY_OK
      
      // Получаем размер статусного сообщения друга
      let size = tox_friend_get_status_message_size(tox, UInt32(friendNumber), &cError)
      
      if cError != TOX_ERR_FRIEND_QUERY_OK {
        let error = ToxError(friendQueryError: cError)
        completion(.failure(error))
        return
      }
      
      // Если размер равен нулю, статусное сообщение не задано
      guard size > 0 else {
        completion(.failure(.emptyFriendStatusMessage))
        return
      }
      
      // Создаем массив для хранения статусного сообщения друга
      var cBuffer = [UInt8](repeating: 0, count: Int(size))
      
      // Получаем статусное сообщение друга
      let result = tox_friend_get_status_message(tox, UInt32(friendNumber), &cBuffer, &cError)
      
      if !result {
        let error = ToxError(friendQueryError: cError)
        completion(.failure(error))
        return
      }
      
      // Преобразуем байты в строку
      if let message = String(bytes: cBuffer, encoding: .utf8) {
        completion(.success(message))
      } else {
        completion(.failure(.invalidStringEncoding))
      }
    }
  }
  
  /// Метод для установки статуса "печатает" для друга.
  /// - Parameters:
  ///   - isTyping: Статус "печатает" (true, если пользователь печатает).
  ///   - friendNumber: Номер друга в сети Tox.
  ///   - completion: Замыкание, вызываемое по завершении операции, с результатом успешного выполнения или ошибкой.
  func setUserIsTyping(
    _ isTyping: Bool,
    forFriendNumber friendNumber: Int32,
    completion: @escaping (Result<Void, ToxError>) -> Void
  ) {
    toxQueue.async { [weak self] in
      guard let self = self, let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      var cError: TOX_ERR_SET_TYPING = TOX_ERR_SET_TYPING_OK
      
      // Устанавливаем статус "печатает" для друга
      let result = tox_self_set_typing(tox, UInt32(friendNumber), isTyping, &cError)
      
      if result {
        completion(.success(()))
      } else {
        let error = ToxError(setTypingError: cError)
        completion(.failure(error))
      }
    }
  }
  
  /// Метод для проверки статуса "печатает" друга.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  ///   - completion: Замыкание, вызываемое по завершении операции, с результатом успешного выполнения или ошибкой.
  func isFriendTyping(
    withFriendNumber friendNumber: Int32,
    completion: @escaping (Result<Bool, ToxError>) -> Void
  ) {
    toxQueue.async { [weak self] in
      guard let self = self, let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      var cError: TOX_ERR_FRIEND_QUERY = TOX_ERR_FRIEND_QUERY_OK
      
      // Проверяем, печатает ли друг
      let isTyping = tox_friend_get_typing(tox, UInt32(friendNumber), &cError)
      
      if cError == TOX_ERR_FRIEND_QUERY_OK {
        completion(.success(isTyping))
      } else {
        let error = ToxError(friendQueryError: cError)
        completion(.failure(error))
      }
    }
  }
  
  /// Метод для получения количества друзей.
  /// - Parameter completion: Замыкание, вызываемое по завершении операции, с результатом успешного выполнения или ошибкой.
  func getFriendsCount(completion: @escaping (Result<Int, ToxError>) -> Void) {
    toxQueue.async { [weak self] in
      guard let self = self, let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      // Получаем количество друзей
      let friendsCount = tox_self_get_friend_list_size(tox)
      
      // Если количество отрицательное, что маловероятно, возвращаем ошибку
      guard friendsCount >= 0 else {
        completion(.failure(.unknown))
        return
      }
      
      completion(.success(Int(friendsCount)))
    }
  }
}

// MARK: - Friend Tox

public extension ToxCore {
  /// Метод для добавления нового друга по адресу. (Требует подтверждения)
  /// - Parameters:
  ///   - address: Адрес друга в сети Tox.
  ///   - message: Приветственное сообщение.
  /// - Returns: Номер друга, если добавление прошло успешно, иначе nil.
  func addFriend(address: String, message: String) -> Int32? {
    guard let tox = self.tox else {
      print("Tox is not initialized.")
      return nil
    }
    
    print("Add friend with address length \(address.count), message length \(message.count)")
    
    guard let cAddress = address.hexStringToBytes() else {
      print("Invalid address format.")
      return nil
    }
    
    let cMessage = message.cString(using: .utf8)!
    let length = message.lengthOfBytes(using: .utf8)
    
    var cError: TOX_ERR_FRIEND_ADD = TOX_ERR_FRIEND_ADD_OK
    let friendNumber: Tox_Friend_Number = tox_friend_add(tox, cAddress, cMessage, length, &cError)
    
    if cError != TOX_ERR_FRIEND_ADD_OK {
      print("Failed to add friend with error code \(cError).")
      return nil
    }
    
    // Преобразование friendNumber в Int32
    guard let result = Int32(exactly: friendNumber) else {
      print("Friend number \(friendNumber) is out of range for Int32.")
      return nil
    }
    
    return result
  }
  
  /// Метод для добавления нового друга по публичному ключу без приветственного сообщения. (Не требует подтверждения)
  /// - Parameters:
  ///   - publicKey: Публичный ключ друга в сети Tox.
  ///   - error: Указатель на объект NSError, который будет заполнен в случае ошибки.
  /// - Returns: Номер друга, если добавление прошло успешно, иначе nil.
  func addFriendWithoutRequest(publicKey: String) -> Int32? {
    guard publicKey.count == Constants.publicKeySize * 2 else {
      print("Public key must be \(Constants.publicKeySize * 2) characters long.")
      return nil
    }
    
    guard let tox = self.tox else {
      print("Tox is not initialized.")
      return nil
    }
    
    print("Add friend with no request and publicKey length \(publicKey.count)")
    
    guard let cPublicKey = publicKey.hexStringToBytes() else {
      print("Invalid public key format.")
      return nil
    }
    
    var cError: TOX_ERR_FRIEND_ADD = TOX_ERR_FRIEND_ADD_OK
    let friendNumber: Tox_Friend_Number = tox_friend_add_norequest(tox, cPublicKey, &cError)
    
    if cError != TOX_ERR_FRIEND_ADD_OK {
      print("Failed to add friend with error code \(cError).")
      return nil
    }
    
    // Преобразование friendNumber в Int32
    guard let result = Int32(exactly: friendNumber) else {
      print("Friend number \(friendNumber) is out of range for Int32.")
      return nil
    }
    
    return result
  }
  
  /// Метод для удаления друга по его номеру.
  /// - Parameters:
  ///   - friendNumber: Номер друга, который нужно удалить.
  ///   - error: Указатель на объект NSError, который будет заполнен в случае ошибки.
  /// - Returns: true, если удаление прошло успешно, иначе false.
  func deleteFriend(friendNumber: Int32) -> Bool {
    guard let tox = self.tox else {
      print("Tox is not initialized.")
      return false
    }
    
    var cError: TOX_ERR_FRIEND_DELETE = TOX_ERR_FRIEND_DELETE_OK
    let result = tox_friend_delete(tox, UInt32(friendNumber), &cError)
    
    if cError != TOX_ERR_FRIEND_DELETE_OK {
      print("Failed to delete friend with error code \(cError).")
      return false
    }
    
    print("Deleting friend with friendNumber \(friendNumber), result \(result)")
    return result
  }
  
  /// Метод для получения номера друга по его публичному ключу.
  /// - Parameters:
  ///   - publicKey: Публичный ключ друга в сети Tox.
  /// - Returns: Номер друга, если он найден, иначе nil.
  func friendNumber(publicKey: String) -> Int32? {
    guard publicKey.count == Constants.publicKeySize * 2 else {
      print("Public key must be \(Constants.publicKeySize * 2) characters long.")
      return nil
    }
    
    guard let tox = self.tox else {
      print("Tox is not initialized.")
      return nil
    }
    
    print("Get friend number with publicKey length \(publicKey.count)")
    
    guard let cPublicKey = publicKey.hexStringToBytes() else {
      print("Invalid public key format.")
      return nil
    }
    
    var cError: TOX_ERR_FRIEND_BY_PUBLIC_KEY = TOX_ERR_FRIEND_BY_PUBLIC_KEY_OK
    let friendNumber: Tox_Friend_Number = tox_friend_by_public_key(tox, cPublicKey, &cError)
    
    if cError != TOX_ERR_FRIEND_BY_PUBLIC_KEY_OK {
      print("Failed to get friend number with error code \(cError).")
      return nil
    }
    
    guard let result = Int32(exactly: friendNumber) else {
      print("Friend number \(friendNumber) is out of range for Int32.")
      return nil
    }
    
    return result
  }
  
  /// Метод для получения публичного ключа друга по его номеру.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  /// - Returns: Публичный ключ в виде строки, если он найден, иначе nil.
  func publicKeyFromFriendNumber(friendNumber: Int32) -> String? {
    guard let tox = self.tox else {
      print("Tox is not initialized.")
      return nil
    }
    
    print("Get public key from friend number \(friendNumber)")
    
    // Выделение памяти для публичного ключа
    let publicKeySize = Constants.publicKeySize
    var cPublicKey = [UInt8](repeating: 0, count: publicKeySize)
    
    var cError: TOX_ERR_FRIEND_GET_PUBLIC_KEY = TOX_ERR_FRIEND_GET_PUBLIC_KEY_OK
    let result = tox_friend_get_public_key(tox, UInt32(friendNumber), &cPublicKey, &cError)
    
    if !result {
      print("Failed to get public key with error code \(cError).")
      return nil
    }
    
    // Преобразуем байты в строку в шестнадцатеричном формате
    let publicKey = cPublicKey.map { String(format: "%02x", $0) }.joined()
    
    return publicKey
  }
  
  /// Метод для проверки существования друга по его номеру.
  /// - Parameter friendNumber: Номер друга в сети Tox.
  /// - Returns: true, если друг существует в списке, иначе false.
  func friendExists(friendNumber: Int32) -> Bool {
    guard let tox = self.tox else {
      print("Tox is not initialized.")
      return false
    }
    
    let result = tox_friend_exists(tox, UInt32(friendNumber))
    print("Friend exists with friend number \(friendNumber): \(result)")
    return result
  }
  
  /// Метод для получения времени последней активности друга по его номеру.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  /// - Returns: Дата и время последней активности, если они доступны, иначе nil.
  func friendGetLastOnline(friendNumber: Int32) -> Date? {
    guard let tox = self.tox else {
      print("Tox is not initialized.")
      return nil
    }
    
    var cError: TOX_ERR_FRIEND_GET_LAST_ONLINE = TOX_ERR_FRIEND_GET_LAST_ONLINE_OK
    let timestamp: UInt64 = tox_friend_get_last_online(tox, UInt32(friendNumber), &cError)
    
    if cError != TOX_ERR_FRIEND_GET_LAST_ONLINE_OK {
      print("Failed to get last online time with error code \(cError).")
      return nil
    }
    
    if timestamp == UInt64.max {
      print("Last online timestamp is not available.")
      return nil
    }
    
    // Преобразуем временную метку в дату
    let lastOnlineDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
    return lastOnlineDate
  }
  
  /// Метод для получения статуса друга по его номеру.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  /// - Returns: Статус друга в виде значения перечисления `UserStatus`, если он доступен, иначе nil.
  func friendStatus(friendNumber: Int32) -> UserStatus? {
    guard let tox = self.tox else {
      print("Tox is not initialized.")
      return nil
    }
    
    var cError: TOX_ERR_FRIEND_QUERY = TOX_ERR_FRIEND_QUERY_OK
    let cStatus: TOX_USER_STATUS = tox_friend_get_status(tox, UInt32(friendNumber), &cError)
    
    if cError != TOX_ERR_FRIEND_QUERY_OK {
      print("Failed to get friend status with error code \(cError).")
      return nil
    }
    
    return UserStatus.userStatusFromCUserStatus(cStatus)
  }
  
  /// Метод для получения статуса подключения друга по его номеру.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  /// - Returns: Статус подключения друга в виде значения перечисления `ConnectionStatus`, если он доступен, иначе nil.
  func friendConnectionStatus(friendNumber: Int32) -> ConnectionStatus? {
    guard let tox = self.tox else {
      print("Tox is not initialized.")
      return nil
    }
    
    var cError: TOX_ERR_FRIEND_QUERY = TOX_ERR_FRIEND_QUERY_OK
    let cStatus: TOX_CONNECTION = tox_friend_get_connection_status(tox, UInt32(friendNumber), &cError)
    
    if cError != TOX_ERR_FRIEND_QUERY_OK {
      print("Failed to get friend connection status with error code \(cError).")
      return nil
    }
    
    return ConnectionStatus.fromCConnectionStatus(cStatus)
  }
  
  /// Метод для получения списка друзей.
  /// - Parameter completion: Замыкание, вызываемое по завершении операции, с результатом успешного выполнения или ошибкой.
  func getFriendList(completion: @escaping (Result<[UInt32], ToxError>) -> Void) {
    toxQueue.async { [weak self] in
      guard let self = self, let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      // Получаем количество друзей
      let friendCount = tox_self_get_friend_list_size(tox)
      guard friendCount > 0 else {
        completion(.success([]))
        return
      }
      
      // Создаем массив для хранения списка друзей
      var friendList = [UInt32](repeating: 0, count: Int(friendCount))
      
      // Вызываем функцию для получения списка друзей
      tox_self_get_friend_list(tox, &friendList)
      
      completion(.success(friendList))
    }
  }
}

// MARK: - Message Tox

public extension ToxCore {
  /// Метод для отправки сообщения другу.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  ///   - message: Сообщение для отправки.
  ///   - messageType: Тип сообщения.
  ///   - completion: Замыкание, вызываемое по завершении операции, с результатом успешной отправки или ошибкой.
  func sendMessage(
    to friendNumber: Int32,
    message: String,
    messageType: ToxMessageType,
    completion: @escaping (Result<Int32, ToxError>) -> Void
  ) {
    toxQueue.async {
      guard let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      // Преобразование типа сообщения
      let cType: TOX_MESSAGE_TYPE
      switch messageType {
      case .normal:
        cType = TOX_MESSAGE_TYPE_NORMAL
      case .action:
        cType = TOX_MESSAGE_TYPE_ACTION
      }
      
      let cMessage = [UInt8](message.utf8)
      var cError: TOX_ERR_FRIEND_SEND_MESSAGE = TOX_ERR_FRIEND_SEND_MESSAGE_OK
      
      let messageId: Int32 = Int32(tox_friend_send_message(
        tox,
        UInt32(friendNumber),
        cType,
        cMessage,
        cMessage.count,
        &cError
      ))
      
      if cError != TOX_ERR_FRIEND_SEND_MESSAGE_OK {
        let error = ToxError(cError: cError)
        completion(.failure(error))
      } else {
        completion(.success(messageId))
      }
    }
  }
  
  /// Метод для отправки сообщения в конференции.
  /// - Parameters:
  ///   - conferenceNumber: Номер конференции в сети Tox.
  ///   - messageType: Тип сообщения.
  ///   - message: Сообщение для отправки.
  ///   - completion: Замыкание, вызываемое по завершении операции, с результатом успешной отправки или ошибкой.
  func sendConferenceMessage(
    to conferenceNumber: Int32,
    messageType: ToxMessageType,
    message: String,
    completion: @escaping (Result<Void, ToxError>) -> Void
  ) {
    toxQueue.async { [weak self] in
      guard let self = self, let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      // Преобразование типа сообщения
      let cmd: Tox_Message_Type
      switch messageType {
      case .normal:
        cmd = TOX_MESSAGE_TYPE_NORMAL
      case .action:
        cmd = TOX_MESSAGE_TYPE_ACTION
      }
      
      let cMessage = [UInt8](message.utf8)
      var cError: TOX_ERR_CONFERENCE_SEND_MESSAGE = TOX_ERR_CONFERENCE_SEND_MESSAGE_OK
      
      let success: Bool = tox_conference_send_message(
        tox,
        UInt32(conferenceNumber),
        cmd,
        cMessage,
        cMessage.count,
        &cError
      )
      
      if success {
        completion(.success(()))
      } else {
        let error = ToxError(conferenceError: cError)
        completion(.failure(error))
      }
    }
  }
}

// MARK: - File Tox

public extension ToxCore {}

// MARK: - Private

public extension ToxCore {
  func addressChecksum(address: [UInt8], length: Int) -> UInt16 {
    var checksum: [UInt8] = [0, 0]
    
    for i in 0..<length {
      checksum[i % 2] ^= address[i]
    }
    
    var check: UInt16 = 0
    memcpy(&check, checksum, MemoryLayout<UInt16>.size)
    
    return check
  }
  
  // Функция для проверки валидности публичного ключа
  func validatePublicKey(_ publicKey: Data) -> Bool {
    // Реализуем проверку валидности публичного ключа
    // Публичный ключ должен быть определенного формата и длины
    return publicKey.count == CRYPTO_PUBLIC_KEY_SIZE
  }
  
  func registerEventHandlers() {
    toxQueue.async {
      guard let tox = self.tox else { return }
      
      tox_callback_self_connection_status(tox, connectionStatusCallback)
      tox_callback_friend_request(tox, friendRequestCallback)
      tox_callback_friend_message(tox, messageCallback)
      tox_callback_file_recv(tox, fileReceiveCallback)
      tox_callback_file_recv_chunk(tox, fileChunkReceiveCallback)
    }
  }
  
  func startEventLoop() {
    timer = DispatchSource.makeTimerSource(queue: toxQueue)
    timer?.schedule(deadline: .now(), repeating: .milliseconds(Int(tox_iteration_interval(tox!))))
    timer?.setEventHandler { [weak self] in
      guard let self = self, let tox = self.tox else { return }
      tox_iterate(tox, nil)
    }
    timer?.resume()
  }
  
  func stopEventLoop() {
    timer?.cancel()
    timer = nil
  }
  
  /// Парсит адрес и извлекает публичный ключ, носпам и чек-сумму.
  /// - Parameter address: Строка адреса для парсинга.
  /// - Returns: Кортеж с публичным ключом, носпамом и чек-суммой.
  public func parseAddress(_ address: String) -> (publicKey: String, noSpam: String, checksum: String)? {
    // Убедимся, что длина строки адреса равна 76 символам.
    guard address.count == 76 else {
      print("Неверный формат адреса. Ожидалось 76 символов.")
      return nil
    }
    
    // Извлекаем публичный ключ, носпам и чек-сумму.
    let publicKey = String(address.prefix(64)).lowercased() // Первые 64 символа.
    let noSpam = String(address.dropFirst(64).prefix(8)).lowercased() // Следующие 8 символов.
    let checksum = String(address.suffix(4)).lowercased() // Последние 4 символа.
    
    // Возвращаем результат в виде кортежа.
    return (publicKey: publicKey, noSpam: noSpam, checksum: checksum)
  }
  
  func bootstrap(completion: @escaping (Result<Void, ToxError>) -> Void) {
    toxQueue.async { [weak self] in
      guard let self, let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      let nodes = ToxNode.parseToxNodes(from: toxNodesJsonString)
      var successfullyConnected = false
      
      for node in nodes {
        guard let publicKeyData = Data(hexString: node.publicKey) else {
          completion(.failure(.unknown))
          return
        }
        
        publicKeyData.withUnsafeBytes { pubKeyPtr in
          let success = tox_bootstrap(tox, node.ipv4, node.port, pubKeyPtr.baseAddress?.assumingMemoryBound(to: UInt8.self), nil)
          if success {
            successfullyConnected = true
            print("✅ Узел загружен: \(node.ipv4)")
          } else {
            print("❌ Ошибка загрузки от узла: \(node.ipv4)")
          }
        }
      }
      
      if successfullyConnected {
        completion(.success(()))
      } else {
        completion(.failure(.null))
      }
    }
  }
}

private enum Constants {
  static let publicKeySize: Int = 32
}
