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
    setSessionTORCallback()
    setFriendStatusCallback()
    setLogCallback()
    setFriendStatusOnlineCallback()
    setFriendTypingCallback()
    setFriendReadReceiptCallback()
  }
}

// MARK: - Callbacks SETS

@available(iOS 16.0, *)
private extension P2PChatManager {
  func setupFileReceiveCallbacks() {
    toxCore.setFileReceiveCallback { friendNumber, fileId, fileName, fileSize in
      print("Получен запрос на файл от друга \(friendNumber), fileId: \(fileId), fileName: \(fileName), fileSize: \(fileSize) байт")
      // Инициализация получения файла
      self.initFileReceive(friendNumber: friendNumber, fileId: fileId, fileName: fileName, fileSize: fileSize)
    }
    
    toxCore.setFileChunkReceiveCallback { friendNumber, fileId, position, data in
      print("Получен чанк данных от друга \(friendNumber), fileId: \(fileId), позиция: \(position), размер данных: \(data.count) байт")
      // Обработка получения чанка
      self.receiveChunk(friendNumber: friendNumber, fileId: fileId, position: position, data: data)
    }
  }
  
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
  
  func setSessionTORCallback() {
    //    torService.stateAction = { [weak self] result in
    //      guard let self else { return }
    //      switch result {
    //      case .none: break
    //      case .started: break
    //      case .connectingProgress: break
    //      case .connected: break
    //      case .stopped:
    //        updateMyOnlineStatus(status: .offline)
    //        torService.stop()
    //        torService.start(completion: { _ in })
    //      case .refreshing:
    //        updateMyOnlineStatus(status: .inProgress)
    //      }
    //      updateSessionState(state: result)
    //    }
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
  func updateFileReceiveCallback(progress: Double, friendId: Int32, filePath: URL?) {
    guard let publicKey = toxCore.publicKeyFromFriendNumber(friendNumber: Int32(friendId)) else {
      return
    }
    
    DispatchQueue.main.async {
      // Отправка уведомления о том что файл доставлен
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.didUpdateFriendReadReceipt.rawValue),
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
  
  // Функция обработки получения чанка данных
  func receiveChunk(friendNumber: Int32, fileId: Int32, position: UInt64, data: Data) {
    // Получение информации о файле
    guard let (filePath, fileSize) = filesInProgress[fileId] else {
      print("Файл не найден для fileId: \(fileId)")
      return
    }
    
    // Запись данных в файл
    guard let fileHandle = try? FileHandle(forWritingTo: filePath) else {
      print("Не удалось открыть файл для записи.")
      return
    }
    
    fileHandle.seek(toFileOffset: position)
    fileHandle.write(data)
    fileHandle.closeFile()
    
    // Проверка, все ли данные получены
    let fileAttributes = try? FileManager.default.attributesOfItem(atPath: filePath.path)
    let currentSize = fileAttributes?[.size] as? UInt64 ?? 0
    
    // Обновление прогресса
    let progress = Double(currentSize) / Double(fileSize) * 100
    print(String(format: "😍 Прогресс получения: %.2f%%", progress))
    updateFileReceiveCallback(progress: progress, friendId: friendNumber, filePath: nil)
    
    if currentSize >= fileSize {
      print("✅ Получение файла завершено: \(filePath.path)")
      // Удаление информации о завершенном файле
      updateFileReceiveCallback(
        progress: progress,
        friendId: friendNumber,
        filePath: getFilePath(
          for: fileId
        )
      )
      filesInProgress.removeValue(forKey: fileId)
    }
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
