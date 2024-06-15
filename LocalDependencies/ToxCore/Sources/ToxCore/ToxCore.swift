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
  
  // MARK: - Init
  
  private init() {}
  
  /// Метод для создания нового объекта Tox с заданными параметрами.
  /// - Parameter options: Опции для настройки Tox.
  /// - Returns: Возвращает true, если инициализация прошла успешно, иначе false.
  public func createNewTox(
    with options: ToxOptions,
    completion: @escaping (Result<Void, ToxError>) -> Void
  ) {
    toxQueue.async {
      var error: Tox_Err_New = TOX_ERR_NEW_OK
      
      var toxOptions = ToxOptions.convertToToxOptions(from: options)
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
  public func stopTox(completion: @escaping (Result<Void, ToxError>) -> Void) {
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
  
  /// Метод для перезапуска сервиса Tox.
  /// - Parameters:
  ///   - options: Опции для настройки Tox.
  ///   - completion: Замыкание, вызываемое после завершения операции.
  public func restartTox(
    with options: ToxOptions,
    completion: @escaping (Result<Void, ToxError>) -> Void
  ) {
    stopTox { [weak self] stopResult in
      switch stopResult {
      case .success:
        self?.createNewTox(with: options) { createResult in
          completion(createResult)
        }
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
  
  /// Функция для получения публичного ключа текущего пользователя.
  /// - Parameter completion: Замыкание, вызываемое после завершения операции. Возвращает результат выполнения в виде:
  ///     - `String`: Публичный ключ текущего пользователя.
  ///     - `ToxError`: Ошибка, если не удалось получить публичный ключ.
  public func getPublicKey(completion: @escaping (Result<String, ToxError>) -> Void) {
    toxQueue.async {
      guard let tox = self.tox else {
        print("Ошибка: Объект Tox не инициализирован.")
        completion(.failure(.null))
        return
      }
      
      var publicKey = [UInt8](repeating: 0, count: Int(TOX_PUBLIC_KEY_SIZE))
      
      // Получаем публичный ключ текущего пользователя
      tox_self_get_public_key(tox, &publicKey)
      
      // Проверяем длину полученного ключа
      if publicKey.count != Int(TOX_PUBLIC_KEY_SIZE) {
        print("Ошибка: Неверный размер публичного ключа.")
        completion(.failure(.unknown))
        return
      }
      
      // Преобразуем данные публичного ключа в строку
      let publicKeyData = Data(publicKey)
      if let publicKeyHex = publicKeyData.toHexString() {
        print("Получен публичный ключ: \(publicKeyHex)")
        completion(.success(publicKeyHex))
      } else {
        print("Ошибка: Не удалось конвертировать публичный ключ в строку.")
        completion(.failure(.unknown))
      }
    }
  }
  
  /// Функция для получения секретного ключа текущего пользователя.
  /// - Parameter completion: Замыкание, вызываемое после завершения операции. Возвращает результат выполнения в виде:
  ///     - `String`: Секретный ключ текущего пользователя.
  ///     - `ToxError`: Ошибка, если не удалось получить секретный ключ.
  public func getSecretKey(completion: @escaping (Result<String, ToxError>) -> Void) {
    toxQueue.async {
      guard let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      var secretKey = [UInt8](repeating: 0, count: Int(TOX_SECRET_KEY_SIZE))
      tox_self_get_secret_key(tox, &secretKey)
      
      let secretKeyData = Data(secretKey)
      if let secretKeyHex = secretKeyData.toHexString() {
        completion(.success(secretKeyHex))
      } else {
        completion(.failure(.unknown))
      }
    }
  }
  
  /// Метод для импорта приватного ключа и восстановления учетной записи.
  /// - Parameters:
  ///   - secretKeyHex: Приватный ключ в шестнадцатеричном формате, который необходимо импортировать.
  ///   - completion: Замыкание, вызываемое после завершения операции. Возвращает результат выполнения в виде:
  ///       - `Void` при успешном восстановлении учетной записи.
  ///       - `ToxError` при ошибке импорта.
  /// - Примечание: Импорт приватного ключа позволяет восстановить учетную запись на новом устройстве. Приватный ключ должен быть точно таким же, как и на старом устройстве, чтобы сохранить доступ к контактам и сообщениям.
  public func importSecretKey(
    _ secretKeyHex: String,
    completion: @escaping (Result<Void, ToxError>) -> Void
  ) {
    toxQueue.async {
      guard let secretKeyData = Data(hexString: secretKeyHex), secretKeyData.count == 32 else {
        completion(.failure(.unknown))
        return
      }
      
      var toxOptions = Tox_Options()
      tox_options_default(&toxOptions)
      
      // Устанавливаем приватный ключ в опциях
      toxOptions.savedata_type = TOX_SAVEDATA_TYPE_SECRET_KEY
      
      secretKeyData.withUnsafeBytes { bytes in
        if let baseAddress = bytes.baseAddress?.assumingMemoryBound(to: UInt8.self) {
          toxOptions.savedata_data = baseAddress
        } else {
          completion(.failure(.null))
          return
        }
      }
      
      toxOptions.savedata_length = secretKeyData.count
      
      var error: TOX_ERR_NEW = TOX_ERR_NEW_OK
      self.tox = tox_new(&toxOptions, &error)
      
      if error == TOX_ERR_NEW_OK {
        completion(.success(()))
      } else {
        let swiftError = ToxError(cError: error)
        completion(.failure(swiftError))
      }
    }
  }
  
  public func generateToxAddress(completion: @escaping (Result<String, ToxError>) -> Void) {
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

// MARK: - Callback

public extension ToxCore {
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
  
  func bootstrap(completion: @escaping (Result<Void, ToxError>) -> Void) {
    toxQueue.async {
      guard let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      let nodes = [
        ("144.217.167.73", 33445, "7E5668E0EE09E19F320AD47902419331FFEE147BB3606769CFBE921A2A2FD34C"),
        ("tox.abilinski.com", 33445, "10C00EB250C3233E343E2AEBA07115A5C28920E9C8D29492F6D00B29049EDC7E"),
        ("205.185.115.131", 53, "3091C6BEB2A993F1C6300C16549FABA67098FF3D62C6D253828B531470B53D68"),
        ("188.225.9.167", 33445, "1911341A83E02503AB1FD6561BD64AF3A9D6C3F12B5FBB656976B2E678644A67"),
        ("tox2.abilinski.com", 33445, "7A6098B590BDC73F9723FC59F82B3F9085A64D1B213AAF8E610FD351930D052D")
      ]
      
      var successfullyConnected = false
      
      for node in nodes {
        guard let publicKeyData = Data(hexString: node.2) else {
          completion(.failure(.unknown))
          return
        }
        
        publicKeyData.withUnsafeBytes { pubKeyPtr in
          let success = tox_bootstrap(tox, node.0, UInt16(node.1), pubKeyPtr.baseAddress?.assumingMemoryBound(to: UInt8.self), nil)
          if success {
            successfullyConnected = true
            print("✅ Узел загружен: \(node.0)")
          } else {
            print("❌ Ошибка загрузки от узла: \(node.0)")
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
