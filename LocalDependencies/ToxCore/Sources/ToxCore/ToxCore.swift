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

@available(iOS 13.0, *)
public extension ToxCore {
  /// Создаёт новый экземпляр Tox с заданными параметрами.
  /// - Parameters:
  ///   - options: Опции для настройки Tox.
  ///   - savedDataString: Сохранённые данные для восстановления состояния Tox, по умолчанию nil.
  ///   - toxNodesJsonString: JSON-строка с конфигурацией узлов Tox.
  ///   - return: Результат операции: успех или ошибка.
  func createNewTox(
    with options: ToxOptions,
    savedDataString: String? = nil,
    toxNodesJsonString: String
  ) async -> Result<Void, ToxError> {
    self.toxNodesJsonString = toxNodesJsonString
    
    return await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self else { return }
        var error: Tox_Err_New = TOX_ERR_NEW_OK
        
        // Преобразуем Swift опции в C-структуру
        var toxOptions = ToxOptions.convertToToxOptions(from: options)
        
        // Передаем указатель на `toxOptions` в функцию
        withUnsafeMutablePointer(to: &toxOptions) { toxOptionsPointer in
          tox_options_set_log_callback(toxOptionsPointer, logCallback)
          tox_options_set_ipv6_enabled(toxOptionsPointer, true)
        }
        self.registerEventHandlers()
        
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
          continuation.resume(returning: .failure(swiftError))
        } else {
          self.bootstrap { result in
            continuation.resume(returning: result)
            if case .success = result {
              self.startEventLoop()
            }
          }
        }
      }
    }
  }
  
  /// Метод для остановки сервиса Tox и освобождения ресурсов.
  func stopTox() async -> Result<Void, ToxError> {
    stopEventLoop()
    
    return await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        tox_kill(tox)
        self.tox = nil
        continuation.resume(returning: .success(()))
      }
    }
  }
  
  /// Перезапускает экземпляр Tox с новыми опциями.
  /// - Parameters:
  ///   - options: Опции для настройки нового экземпляра Tox.
  ///   - toxNodesJsonString: JSON-строка, содержащая конфигурацию узлов Tox.
  ///   - return: Возвращает результат операции: успех или ошибка.
  func restartTox(
    with options: ToxOptions,
    toxNodesJsonString: String
  ) async -> Result<Void, ToxError> {
    let stopResult = await stopTox()
    switch stopResult {
    case .success:
      return await createNewTox(with: options, toxNodesJsonString: toxNodesJsonString)
    case let .failure(error):
      return .failure(error)
    }
  }
}

// MARK: - Callback

public extension ToxCore {
  /// Устанавливает обратный вызов для получения статуса подключения.
  /// - Parameter callback: Функция обратного вызова, которая будет вызвана при изменении статуса подключения.
  func setConnectionStatusCallback(callback: @escaping (ConnectionStatus) -> Void) {
    toxQueue.async { [weak self] in
      guard let self, let tox else { return }
      
      // Создаем и сохраняем контекст с переданным замыканием
      let context = ConnectionStatusContext(callback: callback)
      globalConnectionStatusContext = context
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
    toxQueue.async { [weak self] in
      guard let self, let tox else { return }
      
      // Создаем и сохраняем контекст с переданным замыканием.
      let context = FriendRequestContext(callback: callback)
      globalConnectioFriendRequestContext = context
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
      toxQueue.async { [weak self] in
        guard let self, let tox else { return }
        
        // Сохраняем контекст
        let context = MessageContext(callback: callback)
        globalConnectionMessageContext = context
      }
    }
  
  // Метод для регистрации обратного вызова на изменение состояния подключения друзей
  /// - Parameter callback: Замыкание, вызываемое при изменении состояния подключения друга.
  ///     - friendId: Уникальный идентификатор друга, состояние которого изменилось.
  ///     - connectionStatus: Новое состояние подключения друга.
  func setFriendStatusCallback(
    callback: @escaping (
      _ friendId: Int32,
      _ connectionStatus: ConnectionStatus
    ) -> Void) {
      // Сохраняем контекст
      let context = FriendStatusContext(callback: callback)
      globalFriendStatusContext = context
    }
  
  // Метод для регистрации обратного вызова на логирование
  /// - Parameter callback: Замыкание, вызываемое при получении сообщения лога.
  ///     - file: Имя файла, откуда был вызван лог.
  ///     - level: Уровень логирования.
  ///     - funcName: Имя функции, откуда был вызван лог.
  ///     - message: Текст сообщения.
  ///     - line: Номер строки, где был вызван лог.
  public func setLogCallback(
    callback: @escaping (
      _ file: String,
      _ level: LogLevel,
      _ funcName: String,
      _ line: UInt32,
      _ message: String,
      _ arg: String,
      _ userData: UnsafeMutableRawPointer?
    ) -> Void) {
      let context = LogContext(callback: { (file, toxLogLevel, funcName, line, message, arg, userData) in
        let logLevel = LogLevel.from(toxLogLevel)
        callback(file, logLevel, funcName, line, message, arg, userData)
      })
      globalLogContext = context
    }
  
  /// Устанавливает обратный вызов для получения сообщений статуса друзей.
  /// Этот метод регистрирует коллбэк, который будет вызываться при получении
  /// нового сообщения статуса от друга. Сообщения статуса — это сообщения,
  /// которые друзья могут установить для отображения своего текущего состояния.
  /// - Parameter callback: Замыкание, вызываемое при получении нового сообщения статуса.
  ///   - friendId: Уникальный идентификатор друга, от которого было получено сообщение.
  ///   - message: Текст сообщения статуса.
  func setFriendStatusMessageCallback(
    callback: @escaping (_ friendId: Int32, _ message: String) -> Void) {
      toxQueue.async { [weak self] in
        guard let self, let tox else { return }
        
        // Сохраняем контекст
        let context = StatusMessageContext(callback: callback)
        globalStatusMessageContext = context
      }
    }
  
  /// Устанавливает обратный вызов для изменения статуса друзей.
  /// Этот метод регистрирует коллбэк, который будет вызываться при изменении
  /// статуса друга.
  /// - Parameter callback: Замыкание, вызываемое при изменении статуса.
  ///   - friendId: Уникальный идентификатор друга, чей статус изменился.
  ///   - status: Новый статус пользователя.
  func setFriendStatusOnlineCallback(
    callback: @escaping (_ friendId: Int32, _ status: UserStatus) -> Void) {
      toxQueue.async { [weak self] in
        guard let self, let tox else { return }
        
        // Создаем и сохраняем контекст с переданным замыканием
        let context = FriendStatusOnlineContext(callback: callback)
        globalFriendStatusOnlineContext = context
      }
    }
  
  /// Устанавливает обратный вызов для изменения статуса набора текста друзей.
  /// Этот метод регистрирует коллбэк, который будет вызываться при изменении
  /// статуса набора текста друга.
  /// - Parameter callback: Замыкание, вызываемое при изменении статуса набора текста.
  ///   - friendId: Уникальный идентификатор друга, чей статус набора текста изменился.
  ///   - isTyping: Логическое значение, указывающее, набирает ли текст друг.
  func setFriendTypingCallback(
    callback: @escaping (_ friendId: Int32, _ isTyping: Bool) -> Void) {
      toxQueue.async { [weak self] in
        guard let self, let tox else { return }
        
        // Создаем и сохраняем контекст с переданным замыканием
        let context = TypingContext(callback: callback)
        globalTypingContext = context
      }
    }
  
  /// Устанавливает обратный вызов для получения уведомлений о прочтении сообщений.
  /// Этот метод регистрирует коллбэк, который будет вызываться при получении
  /// уведомления о прочтении сообщения другом.
  /// - Parameter callback: Замыкание, вызываемое при получении уведомления о прочтении.
  ///   - friendId: Уникальный идентификатор друга, который прочитал сообщение.
  ///   - messageId: Идентификатор сообщения, которое было прочитано.
  func setFriendReadReceiptCallback(
    callback: @escaping (UInt32, UInt32) -> Void) {
      toxQueue.async { [weak self] in
        guard let self, let tox else { return }
        
        // Создаем и сохраняем контекст с переданным замыканием
        let context = ReadReceiptContext(callback: callback)
        globalReadReceiptContext = context
        
        // Регистрируем коллбэк для получения уведомлений о прочтении
        tox_callback_friend_read_receipt(tox, friendReadReceiptCallback)
      }
    }
  
  func acceptFile(friendNumber: Int32, fileId: Int32, completion: @escaping (Result<Void, ToxError>) -> Void) {
    toxQueue.async { [weak self] in
      guard let self, let tox else {
        completion(.failure(.null))
        return
      }
      
      var cError: TOX_ERR_FILE_CONTROL = TOX_ERR_FILE_CONTROL_OK
      let result = tox_file_control(
        tox,
        UInt32(friendNumber),
        UInt32(fileId),
        TOX_FILE_CONTROL_RESUME,
        &cError
      )
      
      if result {
        completion(.success(()))
      } else {
        let error = ToxError(fileControlError: cError)
        print("Ошибка при подтверждении приема файла: \(error.localizedDescription), cError: \(cError), friendNumber: \(friendNumber), fileId: \(fileId)")
        completion(.failure(error))
      }
    }
  }
  
  /// Метод для регистрации обратного вызова на получение данных файла.
  /// - Parameter callback: Замыкание, вызываемое при получении части файла. Возвращает следующие параметры:
  ///     - friendId: Уникальный идентификатор друга, отправившего файл.
  ///     - fileId: Уникальный идентификатор файла.
  ///     - position: Позиция начала данных.
  ///     - data: Данные файла.
  func setFileChunkReceiveCallback(callback: @escaping (Int32, Int32, UInt64, Data) -> Void) {
    toxQueue.async { [weak self] in
      guard let self, let tox else { return }
      
      // Сохраняем контекст
      let context = FileChunkReceiveContext(callback: callback)
      globalConnectionFileChunkReceiveContext = context
    }
  }
  
  /// Метод для регистрации обратного вызова на получение уведомлений о новом файле.
  /// - Parameter callback: Замыкание, вызываемое при получении нового файла. Возвращает следующие параметры:
  ///     - friendId: Уникальный идентификатор друга, отправившего файл.
  ///     - fileId: Уникальный идентификатор файла.
  ///     - fileName: Имя файла.
  ///     - fileSize: Размер файла в байтах.
  func setFileReceiveCallback(callback: @escaping (Int32, Int32, String, UInt64) -> Void) {
    toxQueue.async { [weak self] in
      guard let self, let tox else { return }
      
      // Сохраняем контекст
      let context = FileReceiveContext(callback: callback)
      globalConnectionFileReceiveContext = context
    }
  }
  
  /// Устанавливает callback для получения уведомления о подтверждении запроса на передачу файла.
  /// - Parameter callback: Функция обратного вызова, которая будет вызвана при подтверждении запроса на передачу файла.
  ///   Параметры callback:
  ///   - Int32: Идентификатор пользователя.
  ///   - Int32: Идентификатор передачи файла.
  ///   - TOX_FILE_CONTROL: Структура, содержащая информацию о контроле файла.
  func setFileControlCallback(callback: @escaping (Int32, Int32, TOX_FILE_CONTROL) -> Void) {
    globalFileControlCallbackContext = FileControlCallbackContext(callback: callback)
  }
  
  /// Устанавливает callback для запроса на отправку блока данных файла.
  /// - Parameter callback: Функция обратного вызова, которая будет вызвана при запросе на отправку блока данных файла.
  ///   Параметры callback:
  ///   - Int32: Идентификатор пользователя.
  ///   - Int32: Идентификатор передачи файла.
  ///   - UInt64: Смещение данных в файле.
  ///   - Int: Размер блока данных.
  func setFileChunkRequestCallback(callback: @escaping (Int32, Int32, UInt64, Int) -> Void) {
    globalFileChunkRequestCallbackContext = FileChunkRequestCallbackContext(callback: callback)
  }
}

// MARK: - Data Tox

@available(iOS 13.0, *)
public extension ToxCore {
  /// Метод для сохранения состояния Tox в строку.
  /// - Returns: Строка, содержащая сохранённое состояние Tox в формате Base64, или nil, если произошла ошибка.
  func saveToxStateAsString() async -> String? {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          // Логируем ошибку, если Tox не инициализирован
          print("Tox is not initialized.")
          continuation.resume(returning: nil)
          return
        }
        
        // Определяем размер данных для сохранения
        let size = tox_get_savedata_size(tox)
        
        // Выделяем память для сохранения данных
        guard let cData = malloc(size) else {
          // Логируем ошибку, если не удалось выделить память
          print("Failed to allocate memory for saved data.")
          continuation.resume(returning: nil)
          return
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
        continuation.resume(returning: base64String)
      }
    }
  }
  
  
  /// Метод для получения публичного ключа.
  /// - Returns: Публичный ключ в виде строки в шестнадцатеричном формате.
  func getPublicKey() async -> String? {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          print("Tox is not initialized.")
          continuation.resume(returning: nil)
          return
        }
        
        var cPublicKey = [UInt8](repeating: 0, count: Int(TOX_PUBLIC_KEY_SIZE))
        tox_self_get_public_key(tox, &cPublicKey)
        let publicKey = cPublicKey.map { String(format: "%02x", $0) }.joined()
        continuation.resume(returning: publicKey)
      }
    }
  }
  
  /// Метод для получения секретного ключа.
  /// - Returns: Секретный ключ в виде строки в шестнадцатеричном формате.
  func getSecretKey() async -> String? {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          print("Tox is not initialized.")
          continuation.resume(returning: nil)
          return
        }
        
        var cSecretKey = [UInt8](repeating: 0, count: Int(TOX_SECRET_KEY_SIZE))
        tox_self_get_secret_key(tox, &cSecretKey)
        let secretKey = cSecretKey.map { String(format: "%02x", $0) }.joined()
        continuation.resume(returning: secretKey)
      }
    }
  }
  
  /// Метод для установки значения nospam.
  /// - Parameter nospam: Значение nospam.
  func setNospam(_ nospam: UInt32) async {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          print("Tox is not initialized.")
          continuation.resume(returning: ())
          return
        }
        
        tox_self_set_nospam(tox, nospam)
        continuation.resume(returning: ())
      }
    }
  }
  
  /// Метод для получения значения nospam.
  /// - Returns: Значение nospam.
  func getNospam() async -> UInt32? {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          print("Tox is not initialized.")
          continuation.resume(returning: nil)
          return
        }
        
        let nospam = tox_self_get_nospam(tox)
        continuation.resume(returning: nospam)
      }
    }
  }
  
  /// Метод для получения значения ToxAddress.
  /// - Returns: Значение ToxAddress.
  func getToxAddress() async -> String? {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          print("Tox is not initialized.")
          continuation.resume(returning: nil)
          return
        }
        
        let addressSize = 76
        var address = [UInt8](repeating: 0, count: addressSize / 2)
        
        tox_self_get_address(tox, &address)
        
        // Преобразуем байты в строку в шестнадцатеричном формате
        let addressHex = address.map { String(format: "%02x", $0) }.joined()
        continuation.resume(returning: addressHex)
      }
    }
  }
  
  /// Метод для инициализации отправки файла другу.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  ///   - fileName: Имя файла.
  ///   - fileSize: Размер файла в байтах.
  ///   - completion: Замыкание, вызываемое по завершении операции, с результатом успешной отправки или ошибкой.
  func sendFile(
    to friendNumber: Int32,
    fileName: String,
    fileSize: UInt64,
    completion: @escaping (Result<Int32, ToxError>) -> Void
  ) {
    toxQueue.async {
      guard let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      let cFileName = [UInt8](fileName.utf8)
      var cError: TOX_ERR_FILE_SEND = TOX_ERR_FILE_SEND_OK
      
      let fileId: Int32 = Int32(tox_file_send(
        tox,
        UInt32(friendNumber),
        0, // Тип файла - данные
        fileSize,
        nil, // Нет дополнительных метаданных
        cFileName,
        cFileName.count,
        &cError
      ))
      
      if cError != TOX_ERR_FILE_SEND_OK {
        let error = ToxError(fileSendError: cError)
        completion(.failure(error))
      } else {
        completion(.success(fileId))
      }
    }
  }
  
  /// Метод для отправки чанка данных файла.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  ///   - fileId: Идентификатор файла.
  ///   - position: Позиция начала данных.
  ///   - data: Данные файла.
  ///   - completion: Замыкание, вызываемое по завершении операции, с результатом успешной отправки или ошибкой.
  func sendFileChunk(
    to friendNumber: Int32,
    fileId: Int32,
    position: UInt64,
    data: Data,
    completion: @escaping (Result<Void, ToxError>) -> Void
  ) {
    toxQueue.async {
      guard let tox = self.tox else {
        completion(.failure(.null))
        return
      }
      
      var cError: TOX_ERR_FILE_SEND_CHUNK = TOX_ERR_FILE_SEND_CHUNK_OK
      
      data.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) in
        let result = tox_file_send_chunk(
          tox,
          UInt32(friendNumber),
          UInt32(fileId),
          position,
          rawBufferPointer.baseAddress?.assumingMemoryBound(to: UInt8.self),
          data.count,
          &cError
        )
        
        if cError != TOX_ERR_FILE_SEND_CHUNK_OK {
          let error = ToxError(fileSendChunkError: cError)
          completion(.failure(error))
        } else {
          completion(.success(()))
        }
      }
    }
  }
  
  /// Метод для отмены отправки файла.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  ///   - fileId: Идентификатор файла.
  ///   - return: Возвращает результат успешной отправки или ошибки.
  func cancelFileSend(
    to friendNumber: Int32,
    fileId: Int32
  ) async -> Result<Void, ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        var cError: TOX_ERR_FILE_CONTROL = TOX_ERR_FILE_CONTROL_OK
        
        let result = tox_file_control(
          tox,
          UInt32(friendNumber),
          UInt32(fileId),
          TOX_FILE_CONTROL_CANCEL,
          &cError
        )
        
        if result {
          continuation.resume(returning: .success(()))
        } else {
          let error = ToxError(fileControlError: cError)
          continuation.resume(returning: .failure(error))
        }
      }
    }
  }
  
  /// Метод для управления состоянием передачи файла.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  ///   - fileId: Идентификатор файла.
  ///   - control: Команда управления состоянием передачи файла.
  ///   - return: Возвращает результат успешного выполнения или ошибки.
  func controlFileTransfer(
    friendNumber: Int32,
    fileId: Int32,
    control: ToxFileControl
  ) async -> Result<Void, ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        var cError: TOX_ERR_FILE_CONTROL = TOX_ERR_FILE_CONTROL_OK
        let result = tox_file_control(
          tox,
          UInt32(friendNumber),
          UInt32(fileId),
          control.toCFileControl(),
          &cError
        )
        
        if result {
          continuation.resume(returning: .success(()))
        } else {
          let error = ToxError(fileControlError: cError)
          print("Ошибка при управлении состоянием передачи файла: \(error)")
          continuation.resume(returning: .failure(error))
        }
      }
    }
  }
  
  /// Парсит адрес и извлекает публичный ключ, носпам и чек-сумму.
  /// - Parameter address: Строка адреса для парсинга.
  /// - Returns: Кортеж с публичным ключом, носпамом и чек-суммой.
  public func parseAddress(_ address: String) async -> (publicKey: String, noSpam: String, checksum: String)? {
    await withCheckedContinuation { continuation in
      // Убедимся, что длина строки адреса равна 76 символам.
      guard address.count == 76 else {
        print("Неверный формат адреса. Ожидалось 76 символов.")
        continuation.resume(returning: nil)
        return
      }
      
      // Извлекаем публичный ключ, носпам и чек-сумму.
      let publicKey = String(address.prefix(64)).lowercased() // Первые 64 символа.
      let noSpam = String(address.dropFirst(64).prefix(8)).lowercased() // Следующие 8 символов.
      let checksum = String(address.suffix(4)).lowercased() // Последние 4 символа.
      
      // Возвращаем результат в виде кортежа.
      continuation.resume(returning: (publicKey: publicKey, noSpam: noSpam, checksum: checksum))
    }
  }
}

// MARK: - User Tox

@available(iOS 13.0, *)
public extension ToxCore {
  /// Метод для установки статуса пользователя.
  /// - Parameter status: Статус пользователя (online, away, busy).
  func setSelfStatus(_ status: UserStatus) async {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          print("Tox is not initialized.")
          continuation.resume(returning: ())
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
        continuation.resume(returning: ())
      }
    }
  }
  
  /// Метод для установки никнейма пользователя.
  /// - Parameters:
  ///   - name: Новый никнейм пользователя.
  ///   - return: Возвращает результат успешного выполнения или ошибки.
  func setNickname(
    _ name: String
  ) async -> Result<Void, ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        // Проверяем валидность строки
        guard !name.isEmpty else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        // Преобразуем строку в массив байтов
        guard let cName = name.cString(using: .utf8) else {
          continuation.resume(returning: .failure(.unknown))
          return
        }
        let length = name.lengthOfBytes(using: .utf8)
        
        var cError: TOX_ERR_SET_INFO = TOX_ERR_SET_INFO_OK
        
        // Используем функцию tox_self_set_name для установки никнейма
        let result = tox_self_set_name(tox, cName, length, &cError)
        
        if result {
          continuation.resume(returning: .success(()))
        } else {
          let error = ToxError(setInfoError: cError)
          continuation.resume(returning: .failure(error))
        }
      }
    }
  }
  
  /// Метод для получения имени пользователя.
  /// - Parameter return: Возвращает результат успешного выполнения или ошибки
  func getSelfName() async -> Result<String, ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        // Получаем размер имени пользователя
        let length = tox_self_get_name_size(tox)
        
        // Если длина равна нулю, имя не задано
        guard length > 0 else {
          continuation.resume(returning: .failure(.emptyUserName))
          return
        }
        
        // Выделяем память для имени пользователя
        var cName = [UInt8](repeating: 0, count: Int(length))
        
        // Получаем имя пользователя
        tox_self_get_name(tox, &cName)
        
        // Преобразуем полученные байты в строку
        if let name = String(bytes: cName, encoding: .utf8) {
          continuation.resume(returning: .success(name))
        } else {
          continuation.resume(returning: .failure(.invalidStringEncoding))
        }
      }
    }
  }
  
  /// Метод для получения имени друга по его номеру.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  ///   - return: Результат успешного выполнения или ошибки.
  func getFriendName(friendNumber: Int32) async -> Result<String, ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        var cError: TOX_ERR_FRIEND_QUERY = TOX_ERR_FRIEND_QUERY_OK
        
        // Получаем размер имени друга
        let size = tox_friend_get_name_size(tox, UInt32(friendNumber), &cError)
        
        if cError != TOX_ERR_FRIEND_QUERY_OK {
          let error = ToxError(friendQueryError: cError)
          continuation.resume(returning: .failure(error))
          return
        }
        
        // Если размер равен нулю, имя не задано
        guard size > 0 else {
          continuation.resume(returning: .failure(.emptyFriendName))
          return
        }
        
        // Создаем массив для хранения имени друга
        var cName = [UInt8](repeating: 0, count: Int(size))
        
        // Получаем имя друга
        let result = tox_friend_get_name(tox, UInt32(friendNumber), &cName, &cError)
        
        if !result {
          let error = ToxError(friendQueryError: cError)
          continuation.resume(returning: .failure(error))
          return
        }
        
        // Преобразуем байты в строку
        if let name = String(bytes: cName, encoding: .utf8) {
          continuation.resume(returning: .success(name))
        } else {
          continuation.resume(returning: .failure(.invalidStringEncoding))
        }
      }
    }
  }
  
  /// Метод для установки статусного сообщения пользователя.
  /// - Parameters:
  ///   - statusMessage: Новое статусное сообщение пользователя.
  ///   - return: Результат успешного выполнения или ошибки.
  func setUserStatusMessage(
    _ statusMessage: String
  ) async -> Result<Void, ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        // Проверка на пустое сообщение
        guard !statusMessage.isEmpty else {
          continuation.resume(returning: .failure(.emptyStatusMessage))
          return
        }
        
        // Преобразуем сообщение в массив байтов
        guard let cStatusMessage = statusMessage.cString(using: .utf8) else {
          continuation.resume(returning: .failure(.invalidStringEncoding))
          return
        }
        let length = statusMessage.lengthOfBytes(using: .utf8)
        
        var cError: TOX_ERR_SET_INFO = TOX_ERR_SET_INFO_OK
        
        // Используем функцию tox_self_set_status_message для установки статусного сообщения
        let result = tox_self_set_status_message(tox, cStatusMessage, length, &cError)
        
        if result {
          continuation.resume(returning: .success(()))
        } else {
          let error = ToxError(setInfoError: cError)
          continuation.resume(returning: .failure(error))
        }
      }
    }
  }
  
  /// Метод для получения статусного сообщения пользователя.
  /// - Parameter return: Результат успешного выполнения или ошибки
  func getUserStatusMessage() async -> Result<String, ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        // Получаем размер статусного сообщения
        let length = tox_self_get_status_message_size(tox)
        
        // Если длина равна нулю, статусное сообщение не задано
        guard length > 0 else {
          continuation.resume(returning: .failure(.emptyStatusMessage))
          return
        }
        
        // Создаем массив для хранения статусного сообщения
        var cBuffer = [UInt8](repeating: 0, count: Int(length))
        
        // Получаем статусное сообщение
        tox_self_get_status_message(tox, &cBuffer)
        
        // Преобразуем полученные байты в строку
        if let message = String(bytes: cBuffer, encoding: .utf8) {
          continuation.resume(returning: .success(message))
        } else {
          continuation.resume(returning: .failure(.invalidStringEncoding))
        }
      }
    }
  }
  
  /// Метод для получения статусного сообщения друга по его номеру.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  ///   - return: Результат успешного выполнения или ошибки
  func getFriendStatusMessage(friendNumber: Int32) async -> Result<String, ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        var cError: TOX_ERR_FRIEND_QUERY = TOX_ERR_FRIEND_QUERY_OK
        
        // Получаем размер статусного сообщения друга
        let size = tox_friend_get_status_message_size(tox, UInt32(friendNumber), &cError)
        
        if cError != TOX_ERR_FRIEND_QUERY_OK {
          let error = ToxError(friendQueryError: cError)
          continuation.resume(returning: .failure(error))
          return
        }
        
        // Если размер равен нулю, статусное сообщение не задано
        guard size > 0 else {
          continuation.resume(returning: .failure(.emptyFriendStatusMessage))
          return
        }
        
        // Создаем массив для хранения статусного сообщения друга
        var cBuffer = [UInt8](repeating: 0, count: Int(size))
        
        // Получаем статусное сообщение друга
        let result = tox_friend_get_status_message(tox, UInt32(friendNumber), &cBuffer, &cError)
        
        if !result {
          let error = ToxError(friendQueryError: cError)
          continuation.resume(returning: .failure(error))
          return
        }
        
        // Преобразуем байты в строку
        if let message = String(bytes: cBuffer, encoding: .utf8) {
          continuation.resume(returning: .success(message))
        } else {
          continuation.resume(returning: .failure(.invalidStringEncoding))
        }
      }
    }
  }
  
  /// Метод для установки статуса "печатает" для друга.
  /// - Parameters:
  ///   - isTyping: Статус "печатает" (true, если пользователь печатает).
  ///   - friendNumber: Номер друга в сети Tox.
  ///   - return: Результат успешного выполнения или ошибки.
  func setUserIsTyping(
    _ isTyping: Bool,
    forFriendNumber friendNumber: Int32
  ) async -> Result<Void, ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        var cError: TOX_ERR_SET_TYPING = TOX_ERR_SET_TYPING_OK
        
        // Устанавливаем статус "печатает" для друга
        let result = tox_self_set_typing(tox, UInt32(friendNumber), isTyping, &cError)
        
        if result {
          continuation.resume(returning: .success(()))
        } else {
          let error = ToxError(setTypingError: cError)
          continuation.resume(returning: .failure(error))
        }
      }
    }
  }
  
  /// Метод для проверки статуса "печатает" друга.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  ///   - return: Результат успешного выполнения или ошибки.
  func isFriendTyping(withFriendNumber friendNumber: Int32) async -> Result<Bool, ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        var cError: TOX_ERR_FRIEND_QUERY = TOX_ERR_FRIEND_QUERY_OK
        
        // Проверяем, печатает ли друг
        let isTyping = tox_friend_get_typing(tox, UInt32(friendNumber), &cError)
        
        if cError == TOX_ERR_FRIEND_QUERY_OK {
          continuation.resume(returning: .success(isTyping))
        } else {
          let error = ToxError(friendQueryError: cError)
          continuation.resume(returning: .failure(error))
        }
      }
    }
  }
  
  /// Метод для получения количества друзей.
  /// - Parameter return: Результат успешного выполнения или ошибки.
  func getFriendsCount() async -> Result<Int, ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        // Получаем количество друзей
        let friendsCount = tox_self_get_friend_list_size(tox)
        
        // Если количество отрицательное, что маловероятно, возвращаем ошибку
        guard friendsCount >= 0 else {
          continuation.resume(returning: .failure(.unknown))
          return
        }
        
        continuation.resume(returning: .success(Int(friendsCount)))
      }
    }
  }
}

// MARK: - Friend Tox

@available(iOS 13.0, *)
public extension ToxCore {
  /// Метод для добавления нового друга по адресу. (Требует подтверждения)
  /// - Parameters:
  ///   - address: Адрес друга в сети Tox.
  ///   - message: Приветственное сообщение.
  /// - Returns: Номер друга, если добавление прошло успешно, иначе nil.
  func addFriend(address: String, message: String) async -> Int32? {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          print("Tox is not initialized.")
          continuation.resume(returning: nil)
          return
        }
        
        print("Add friend with address length \(address.count), message length \(message.count)")
        
        guard let cAddress = address.hexStringToBytes() else {
          print("Invalid address format.")
          continuation.resume(returning: nil)
          return
        }
        
        let cMessage = message.cString(using: .utf8)!
        let length = message.lengthOfBytes(using: .utf8)
        
        var cError: TOX_ERR_FRIEND_ADD = TOX_ERR_FRIEND_ADD_OK
        let friendNumber: Tox_Friend_Number = tox_friend_add(tox, cAddress, cMessage, length, &cError)
        
        if cError != TOX_ERR_FRIEND_ADD_OK {
          print("Failed to add friend with error code \(cError).")
          continuation.resume(returning: nil)
          return
        }
        
        // Преобразование friendNumber в Int32
        guard let result = Int32(exactly: friendNumber) else {
          print("Friend number \(friendNumber) is out of range for Int32.")
          continuation.resume(returning: nil)
          return
        }
        
        continuation.resume(returning: result)
      }
    }
  }
  
  /// Используя метод confirmFriendRequest, вы подтверждаете запрос на добавление в друзья, зная публичный ключ отправителя.
  /// Этот метод принимает публичный ключ друга и добавляет его в список друзей без отправки дополнительного сообщения.
  /// - Parameters:
  ///   - publicKey: Строка, представляющая публичный ключ друга. Этот ключ используется для идентификации пользователя в сети Tox.
  ///   - completion: Замыкание, вызываемое после завершения операции. Возвращает результат выполнения в виде:
  ///       - `Int32`: Уникальный идентификатор друга в списке друзей. Этот идентификатор используется для управления другом (отправка сообщений, проверка статуса и т.д.).
  ///       - `ToxError`: Ошибка, если запрос не удалось подтвердить.
  public func confirmFriendRequest(
    with publicKey: String
  ) async -> Result<Int32, ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async {[weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        // Конвертируем строку публичного ключа в данные.
        guard let publicKeyData = Data(hexString: publicKey) else {
          continuation.resume(returning: .failure(.unknown))
          return
        }
        
        // Переменная для хранения ошибки.
        var error: TOX_ERR_FRIEND_ADD = TOX_ERR_FRIEND_ADD_OK
        // Добавляем друга, используя публичный ключ.
        let friendId = publicKeyData.withUnsafeBytes { pubKeyPtr in
          tox_friend_add_norequest(tox, pubKeyPtr.baseAddress?.assumingMemoryBound(to: UInt8.self), &error)
        }
        
        // Проверяем на наличие ошибки и возвращаем результат.
        if error == TOX_ERR_FRIEND_ADD_OK {
          continuation.resume(returning: .success(Int32(friendId)))
        } else {
          let swiftError = ToxError(friendAddError: error)
          continuation.resume(returning: .failure(swiftError))
        }
      }
    }
  }
  
  /// Метод для добавления нового друга по публичному ключу без приветственного сообщения. (Не требует подтверждения)
  /// - Parameters:
  ///   - publicKey: Публичный ключ друга в сети Tox.
  ///   - error: Указатель на объект NSError, который будет заполнен в случае ошибки.
  /// - Returns: Номер друга, если добавление прошло успешно, иначе nil.
  func addFriendWithoutRequest(publicKey: String) async -> Int32? {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard publicKey.count == Constants.publicKeySize * 2 else {
          print("Public key must be \(Constants.publicKeySize * 2) characters long.")
          continuation.resume(returning: nil)
          return
        }
        
        guard let self, let tox else {
          print("Tox is not initialized.")
          continuation.resume(returning: nil)
          return
        }
        
        print("Add friend with no request and publicKey length \(publicKey.count)")
        
        guard let cPublicKey = publicKey.hexStringToBytes() else {
          print("Invalid public key format.")
          continuation.resume(returning: nil)
          return
        }
        
        var cError: TOX_ERR_FRIEND_ADD = TOX_ERR_FRIEND_ADD_OK
        let friendNumber: Tox_Friend_Number = tox_friend_add_norequest(tox, cPublicKey, &cError)
        
        if cError != TOX_ERR_FRIEND_ADD_OK {
          print("Failed to add friend with error code \(cError).")
          continuation.resume(returning: nil)
          return
        }
        
        // Преобразование friendNumber в Int32
        guard let result = Int32(exactly: friendNumber) else {
          print("Friend number \(friendNumber) is out of range for Int32.")
          continuation.resume(returning: nil)
          return
        }
        
        continuation.resume(returning: result)
      }
    }
  }
  
  /// Метод для удаления друга по его номеру.
  /// - Parameters:
  ///   - friendNumber: Номер друга, который нужно удалить.
  ///   - error: Указатель на объект NSError, который будет заполнен в случае ошибки.
  /// - Returns: true, если удаление прошло успешно, иначе false.
  func deleteFriend(friendNumber: Int32) async -> Bool {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          print("Tox is not initialized.")
          continuation.resume(returning: false)
          return
        }
        
        var cError: TOX_ERR_FRIEND_DELETE = TOX_ERR_FRIEND_DELETE_OK
        let result = tox_friend_delete(tox, UInt32(friendNumber), &cError)
        
        if cError != TOX_ERR_FRIEND_DELETE_OK {
          print("Failed to delete friend with error code \(cError).")
          continuation.resume(returning: false)
          return
        }
        
        print("Deleting friend with friendNumber \(friendNumber), result \(result)")
        continuation.resume(returning: result)
      }
    }
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
  func friendGetLastOnline(friendNumber: Int32) async -> Date? {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          print("Tox is not initialized.")
          continuation.resume(returning: nil)
          return
        }
        
        var cError: TOX_ERR_FRIEND_GET_LAST_ONLINE = TOX_ERR_FRIEND_GET_LAST_ONLINE_OK
        let timestamp: UInt64 = tox_friend_get_last_online(tox, UInt32(friendNumber), &cError)
        
        if cError != TOX_ERR_FRIEND_GET_LAST_ONLINE_OK {
          print("Failed to get last online time with error code \(cError).")
          continuation.resume(returning: nil)
          return
        }
        
        if timestamp == UInt64.max {
          print("Last online timestamp is not available.")
          continuation.resume(returning: nil)
          return
        }
        
        // Преобразуем временную метку в дату
        let lastOnlineDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
        continuation.resume(returning: lastOnlineDate)
      }
    }
  }
  
  /// Метод для получения статуса подключения друга по его номеру.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  /// - Returns: Статус подключения друга в виде значения перечисления `ConnectionStatus`, если он доступен, иначе nil.
  func friendConnectionStatus(friendNumber: Int32) async -> ConnectionStatus? {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          print("Tox is not initialized.")
          continuation.resume(returning: nil)
          return
        }
        
        var cError: TOX_ERR_FRIEND_QUERY = TOX_ERR_FRIEND_QUERY_OK
        let cStatus: TOX_CONNECTION = tox_friend_get_connection_status(tox, UInt32(friendNumber), &cError)
        
        if cError != TOX_ERR_FRIEND_QUERY_OK {
          print("Failed to get friend connection status with error code \(cError).")
          continuation.resume(returning: nil)
          return
        }
        
        continuation.resume(returning: ConnectionStatus.fromCConnectionStatus(cStatus))
      }
    }
  }
  
  /// Метод для получения списка друзей.
  /// - Parameter return: Результатом успешного выполнения или ошибкой.
  func getFriendList() async -> Result<[UInt32], ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        // Получаем количество друзей
        let friendCount = tox_self_get_friend_list_size(tox)
        guard friendCount > 0 else {
          continuation.resume(returning: .success([]))
          return
        }
        
        // Создаем массив для хранения списка друзей
        var friendList = [UInt32](repeating: 0, count: Int(friendCount))
        
        // Вызываем функцию для получения списка друзей
        tox_self_get_friend_list(tox, &friendList)
        
        continuation.resume(returning: .success(friendList))
      }
    }
  }
}

// MARK: - Message Tox

@available(iOS 13.0, *)
public extension ToxCore {
  /// Метод для отправки сообщения другу.
  /// - Parameters:
  ///   - friendNumber: Номер друга в сети Tox.
  ///   - message: Сообщение для отправки.
  ///   - messageType: Тип сообщения.
  ///   - return: Результат успешной отправки или ошибки.
  func sendMessage(
    to friendNumber: Int32,
    message: String,
    messageType: ToxMessageType
  ) async -> Result<Int32, ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
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
          continuation.resume(returning: .failure(error))
        } else {
          continuation.resume(returning: .success(messageId))
        }
      }
    }
  }
  
  /// Метод для отправки сообщения в конференции.
  /// - Parameters:
  ///   - conferenceNumber: Номер конференции в сети Tox.
  ///   - messageType: Тип сообщения.
  ///   - message: Сообщение для отправки.
  ///   - return: Результат успешной отправки или ошибки.
  func sendConferenceMessage(
    to conferenceNumber: Int32,
    messageType: ToxMessageType,
    message: String
  ) async -> Result<Void, ToxError> {
    await withCheckedContinuation { continuation in
      toxQueue.async { [weak self] in
        guard let self, let tox else {
          continuation.resume(returning: .failure(.null))
          return
        }
        
        // Преобразование типа сообщения
        let cmd: TOX_MESSAGE_TYPE
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
          continuation.resume(returning: .success(()))
        } else {
          let error = ToxError(conferenceError: cError)
          continuation.resume(returning: .failure(error))
        }
      }
    }
  }
}

// MARK: - File Tox

public extension ToxCore {}

// MARK: - Private

private extension ToxCore {
  func registerEventHandlers() {
    toxQueue.async { [weak self] in
      guard let self, let tox else { return }
      tox_callback_self_connection_status(tox, connectionStatusCallback)
      tox_callback_friend_message(tox, messageCallback)
      tox_callback_friend_connection_status(tox, friendStatusCallback)
      tox_callback_friend_request(tox, friendRequestCallback)
      tox_callback_friend_status_message(tox, friendStatusMessageCallback)
      tox_callback_friend_status(tox, friendStatusOnlineCallback)
      tox_callback_friend_typing(tox, friendTypingCallback)
      tox_callback_friend_read_receipt(tox, friendReadReceiptCallback)
      tox_callback_file_recv(tox, fileReceiveCallback)
      tox_callback_file_recv_chunk(tox, fileChunkReceiveCallback)
      tox_callback_file_recv_control(tox, fileControlCallback)
      tox_callback_file_chunk_request(tox, fileChunkRequestCallback)
    }
  }
  
  func startEventLoop() {
    guard let tox else { return }
    timer = DispatchSource.makeTimerSource(queue: toxQueue)
    timer?.schedule(deadline: .now(), repeating: .milliseconds(Int(tox_iteration_interval(tox))))
    timer?.setEventHandler { [weak self] in
      guard let self else { return }
      tox_iterate(tox, nil)
    }
    timer?.resume()
  }
  
  func stopEventLoop() {
    timer?.cancel()
    timer = nil
  }
  
  func bootstrap(completion: @escaping (Result<Void, ToxError>) -> Void) {
    toxQueue.async { [weak self] in
      guard let self, let tox else {
        completion(.failure(.null))
        return
      }
      
      let nodes = ToxNode.parseToxNodes(from: self.toxNodesJsonString)
      var successfullyConnected = false
      
      for node in nodes {
        guard let publicKeyData = Data(hexString: node.publicKey) else {
          print("❌ Ошибка: Некорректный публичный ключ для узла \(node.ipv4) или \(node.ipv6 ?? "No IPv6")")
          continue
        }
        
        publicKeyData.withUnsafeBytes { pubKeyPtr in
          // Попытка загрузки узла по IPv4
          if !node.ipv4.isEmpty {
            let ipv4Success = tox_bootstrap(tox, node.ipv4, node.port, pubKeyPtr.baseAddress?.assumingMemoryBound(to: UInt8.self), nil)
            if ipv4Success {
              successfullyConnected = true
              self.addTCPRelay(tox, address: node.ipv4, port: node.port, pubKeyPointer: pubKeyPtr)
            } else {
              print("❌ Ошибка загрузки узла по IPv4: \(node.ipv4)")
            }
          }
          
          // Попытка загрузки узла по IPv6, если адрес доступен
          if let ipv6 = node.ipv6, !ipv6.isEmpty {
            let ipv6Success = tox_bootstrap(tox, ipv6, node.port, pubKeyPtr.baseAddress?.assumingMemoryBound(to: UInt8.self), nil)
            if ipv6Success {
              successfullyConnected = true
              self.addTCPRelay(tox, address: ipv6, port: node.port, pubKeyPointer: pubKeyPtr)
            } else {
              print("❌ Ошибка загрузки узла по IPv6: \(ipv6)")
            }
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
  
  func addTCPRelay(
    _ tox: UnsafeMutablePointer<Tox>,
    address: String,
    port: UInt16,
    pubKeyPointer: UnsafeRawBufferPointer
  ) {
    var error: TOX_ERR_BOOTSTRAP = TOX_ERR_BOOTSTRAP_OK
    let result = tox_add_tcp_relay(
      tox,
      address,
      port,
      pubKeyPointer.baseAddress?.assumingMemoryBound(to: UInt8.self),
      &error
    )
  }
}

// MARK: - Constants

private enum Constants {
  static let publicKeySize: Int = 32
}
