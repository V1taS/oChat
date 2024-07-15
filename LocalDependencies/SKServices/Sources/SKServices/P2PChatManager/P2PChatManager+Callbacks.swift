//
//  P2PChatManager+Callbacks.swift
//  SKServices
//
//  Created by Vitalii Sosin on 22.06.2024.
//

import SwiftUI
import SKAbstractions
import ToxCore

// MARK: - ConfigurationCallback

@available(iOS 16.0, *)
extension P2PChatManager {
  func configurationCallback() {
    setConnectionStatusCallback()
    setFriendRequestCallback()
    setMessageCallback()
    setFriendStatusCallback()
    setLogCallback()
    setFriendStatusOnlineCallback()
    setFriendTypingCallback()
    setFriendReadReceiptCallback()
    setupFileReceiveCallbacks()
  }
}

// MARK: - Callbacks SETS

@available(iOS 16.0, *)
private extension P2PChatManager {
  func setupFileReceiveCallbacks() {
    toxCore.setFileReceiveCallback { [weak self] friendNumber, fileId, fileName, fileSize in
      guard let self else { return }
      print("Получен запрос на файл от друга \(friendNumber), fileId: \(fileId), fileName: \(fileName), fileSize: \(fileSize) байт")
      
      // MARK: - ШАГ 2 Подтверждение запроса от юзера 1
      
      fileInfo = (friendNumber, fileId, fileName, fileSize)
      self.toxCore.acceptFile(friendNumber: friendNumber, fileId: fileId) { _ in }
    }
    
    toxCore.setFileChunkReceiveCallback { [weak self] friendNumber, fileId, position, data in
      guard let self, let fileInfo, fileInfo.friendNumber == friendNumber, fileInfo.fileId == fileId else {
        print("Ошибка: информация о файле не найдена или не соответствует текущему запросу")
        return
      }
      
      // Для получения директории Documents
      guard let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
        print("Ошибка: не удалось получить путь к директории Documents")
        return
      }
      
      let fileURL = documentDirectory.appendingPathComponent(fileInfo.fileName)
      
      writeFileChunk(
        data: data,
        position: position,
        to: fileURL,
        completion: { [weak self] result in
          guard let self else { return }
          switch result {
          case let .success(progress):
            if progress == 100 {
              print("fileInfo: \(fileInfo.fileSize)")
              if let fileData = try? Data(contentsOf: fileURL) {
                print("file: \(fileData.count)")
              } else {
                print("Ошибка: не удалось прочитать данные из файла")
              }
            }
            
            updateFileReceiveCallback(
              progress: progress,
              friendId: friendNumber,
              filePath: fileURL
            )
          case .failure:
            print("❌ Что-то пошло не так")
            // TODO: - Очищаем хранилище куда получали файлик
            break
          }
        }
      )
    }
    
    // MARK: - Получение подтверждения запроса на передачу файла (Просто уведомление)
    toxCore.setFileControlCallback { friendNumber, fileId, control in }
    
    toxCore.setFileChunkRequestCallback { [weak self] friendNumber, fileId, position, length in
      guard let self else { return }
      sendChunk(
        to: friendNumber,
        fileId: fileId,
        position: position,
        length: length,
        completion: { [weak self] result in
          guard let self else { return }
          switch result {
          case let .success(progress):
            updateFileSenderCallback(progress: progress, friendId: friendNumber)
            dataManagerService.clearTemporaryDirectory()
          case .failure:
            dataManagerService.clearTemporaryDirectory()
            updateFileSenderErrorCallback(friendId: friendNumber)
          }
        }
      )
    }
  }
  
  func writeFileChunk(
    data: Data,
    position: UInt64,
    to fileURL: URL,
    completion: @escaping (Result<Double, Error>) -> Void
  ) {
    guard let fileInfo else {
      return
    }
    do {
      let fileManager = FileManager.default
      let fileHandle: FileHandle
      
      // Проверяем, существует ли временная директория
      let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
      if !fileManager.fileExists(atPath: temporaryDirectory.path) {
        try fileManager.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true, attributes: nil)
      }
      
      // Проверяем, существует ли файл и создаем его при необходимости
      if fileManager.fileExists(atPath: fileURL.path) {
        fileHandle = try FileHandle(forUpdating: fileURL)
      } else {
        fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        fileHandle = try FileHandle(forWritingTo: fileURL)
      }
      
      // Записываем данные в файл
      fileHandle.seek(toFileOffset: position)
      fileHandle.write(data)
      fileHandle.closeFile()
      
      // Рассчитываем прогресс
      let currentSize = (try fileManager.attributesOfItem(atPath: fileURL.path)[.size] as? UInt64) ?? 0
      let progress = Double(currentSize) / Double(fileInfo.fileSize) * 100.0
      completion(.success(progress))
    } catch {
      completion(.failure(error))
    }
  }
}

@available(iOS 16.0, *)
private extension P2PChatManager {
  func setFriendReadReceiptCallback() {
    toxCore.setFriendReadReceiptCallback { [weak self] friendId, messageId in
      self?.updateFriendReadReceiptCallback(friendId, messageId)
    }
  }
  
  func setFriendTypingCallback() {
    toxCore.setFriendTypingCallback { [weak self] friendId, isTyping in
      self?.updateFriendTyping(friendId, isTyping)
    }
  }
  
  func setFriendStatusOnlineCallback() {
    toxCore.setFriendStatusOnlineCallback { [weak self] friendId, status in
      self?.updateFriendStatusOnline(friendId: friendId, status: status)
    }
  }
  
  func setFriendStatusCallback() {
    toxCore.setFriendStatusCallback { [weak self] friendId, connectionStatus in
      let status: UserStatus
      switch connectionStatus {
      case .none:
        status = .away
      case .tcp:
        status = .online
      case .udp:
        status = .online
      }
      self?.updateFriendStatusOnline(friendId: friendId, status: status)
    }
  }
  
  func setLogCallback() {
    toxCore.setLogCallback { file, level, funcName, line, message, arg, userData in
      let logMessage = "\(file):\(line) - \(funcName): \(message) [\(arg)]"
      
      switch level {
      case .trace:
        print("🛤️ TRACE: \(logMessage)")
      case .debug:
        print("🔍 DEBUG: \(logMessage)")
      case .info:
        print("ℹ️ INFO: \(logMessage)")
      case .warning:
        print("⚠️ WARNING: \(logMessage)")
      case .error:
        print("❌ ERROR: \(logMessage)")
      }
    }
  }
  
  func setFriendRequestCallback() {
    toxCore.setFriendRequestCallback { [weak self] toxPublicKey, jsonString in
      guard let self else { return }
      updateDidReceiveRequestChat(jsonString: jsonString, toxPublicKey: toxPublicKey)
    }
  }
  
  func setConnectionStatusCallback() {
    toxCore.setConnectionStatusCallback { [weak self] connectionStatus in
      guard let self else { return }
      switch connectionStatus {
      case .none:
        updateMyOnlineStatus(status: .offline)
      case .tcp:
        updateMyOnlineStatus(status: .online)
      case .udp:
        updateMyOnlineStatus(status: .online)
      }
    }
  }
  
  func setMessageCallback() {
    toxCore.setMessageCallback { [weak self] friendId, jsonString in
      guard let self else { return }
      updateDidReceiveMessage(jsonString: jsonString, friendId: friendId)
    }
  }
}

// MARK: - Callbacks UPDATES

@available(iOS 16.0, *)
private extension P2PChatManager {
  func updateFileSenderErrorCallback(friendId: Int32) {
    guard let publicKey = toxCore.publicKeyFromFriendNumber(friendNumber: Int32(friendId)) else {
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      // Отправка уведомления что файл отправляется с ошибкой
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.didUpdateFileErrorSend.rawValue),
        object: nil,
        userInfo: [
          "publicKey": publicKey,
          "messageID": cacheMessengerModel?.messageID
        ]
      )
    }
  }
  
  func updateFileSenderCallback(progress: Double, friendId: Int32) {
    guard let publicKey = toxCore.publicKeyFromFriendNumber(friendNumber: Int32(friendId)) else {
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      // Отправка уведомления что файл отправляется
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.didUpdateFileSend.rawValue),
        object: nil,
        userInfo: [
          "publicKey": publicKey,
          "progress": progress,
          "messageID": cacheMessengerModel?.messageID
        ]
      )
    }
  }
  
  func updateFileReceiveCallback(progress: Double, friendId: Int32, filePath: URL?) {
    guard let publicKey = toxCore.publicKeyFromFriendNumber(friendNumber: Int32(friendId)) else {
      return
    }
    
    DispatchQueue.main.async {
      // Отправка уведомления что файл получается
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.didUpdateFileReceive.rawValue),
        object: nil,
        userInfo: [
          "publicKey": publicKey,
          "progress": progress,
          "filePath": filePath
        ]
      )
    }
  }
  
  func updateFriendReadReceiptCallback(_ friendId: UInt32, _ messageId: UInt32) {
    guard let publicKey = toxCore.publicKeyFromFriendNumber(friendNumber: Int32(friendId)) else {
      return
    }
    
    DispatchQueue.main.async {
      // Отправка уведомления о том что сообщение доставлено
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.didUpdateFriendReadReceipt.rawValue),
        object: nil,
        userInfo: [
          "publicKey": publicKey,
          "messageId": messageId
        ]
      )
    }
  }
  
  func updateFriendTyping(_ friendId: Int32, _ isTyping: Bool) {
    guard let publicKey = toxCore.publicKeyFromFriendNumber(friendNumber: friendId) else {
      return
    }
    
    DispatchQueue.main.async {
      // Отправка уведомления о том печатает ли пользователь сейчас
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.isTyping.rawValue),
        object: nil,
        userInfo: [
          "publicKey": publicKey,
          "isTyping": isTyping
        ]
      )
    }
  }
  
  func updateFriendStatusOnline(friendId: Int32, status: UserStatus) {
    guard let publicKey = toxCore.publicKeyFromFriendNumber(friendNumber: friendId) else {
      return
    }
    
    DispatchQueue.main.async {
      // Отправка уведомления об изменении статуса ОНЛАЙН/ОФФ ЛАЙН друзей
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.didUpdateFriendOnlineStatus.rawValue),
        object: nil,
        userInfo: [
          "publicKey": publicKey,
          "status": status.mapTo()
        ]
      )
    }
  }
  
  func updateMyOnlineStatus(status: MessengerModel.Status) {
    DispatchQueue.main.async {
      // Отправка уведомления об изменении статуса ОНЛАЙН/ОФФ ЛАЙН
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.didUpdateMyOnlineStatus.rawValue),
        object: nil,
        userInfo: ["onlineStatus": status]
      )
    }
  }
  
  func updateDidReceiveMessage(jsonString: String?, friendId: Int32) {
    guard let jsonString,
          let jsonData = jsonString.data(using: .utf8),
          let dto = try? JSONDecoder().decode(MessengerNetworkRequestDTO.self, from: jsonData) else {
      return
    }
    
    DispatchQueue.main.async {
      // Отправка уведомления о получении нового сообщения
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.didReceiveMessage.rawValue),
        object: nil,
        userInfo: [
          "data": dto.mapToModel(),
          "toxFriendId": friendId
        ]
      )
    }
  }
  
  func updateDidReceiveRequestChat(jsonString: String?, toxPublicKey: String) {
    guard let jsonString,
          let jsonData = jsonString.data(using: .utf8),
          let dto = try? JSONDecoder().decode(MessengerNetworkRequestDTO.self, from: jsonData) else {
      return
    }
    
    DispatchQueue.main.async {
      // Отправка уведомления о начале нового чата
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.didInitiateChat.rawValue),
        object: nil,
        userInfo: [
          "requestChat": dto.mapToModel(),
          "toxPublicKey": toxPublicKey
        ]
      )
    }
  }
  
  func updateSessionState(state: TorSessionState) {
    DispatchQueue.main.async {
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.sessionState.rawValue),
        object: nil,
        userInfo: ["sessionState": state]
      )
    }
  }
}

// MARK: - Private

@available(iOS 16.0, *)
private extension P2PChatManager {
  func initFileReceive(friendNumber: Int32, fileId: Int32, fileName: String, fileSize: UInt64) {
    // Создание или открытие файла для записи данных
    let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    
    guard FileManager.default.createFile(atPath: filePath.path, contents: nil, attributes: nil) else {
      print("Не удалось создать файл для записи.")
      return
    }
    
    // Сохранение информации о файле (можно использовать словарь или другую структуру для отслеживания нескольких файлов)
    filesInProgress[fileId] = (filePath, fileSize)
  }
  
  // Функция для получения пути к завершенному файлу
  func getFilePath(for fileId: Int32) -> URL? {
    guard let (filePath, _) = filesInProgress[fileId] else {
      print("Файл не найден для fileId: \(fileId)")
      return nil
    }
    return filePath
  }
}

// Хранение информации о получаемых файлах
private var filesInProgress: [Int32: (URL, UInt64)] = [:]
