//
//  IP2PChatManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.06.2024.
//

import Foundation

/// Протокол управления чатом P2P через Tor.
public protocol IP2PChatManager {
  /// Запускает менеджер чата с возможностью передачи данных о состоянии.
  /// - Parameter saveDataString: Строка с сохранёнными данными, если таковые имеются.
  /// - Returns: Результат выполнения операции.
  func start(saveDataString: String?) async throws
  
  /// Получить строку состояния Tox.
  /// - Returns: Строка с сохранённым состоянием Tox в формате Base64.
  func toxStateAsString() async -> String?
  
  /// Получить адрес Tox.
  /// - Returns: Адрес Tox в виде строки.
  func getToxAddress() async -> String?
  
  /// Метод для получения публичного ключа.
  /// - Returns: Публичный ключ в виде строки.
  func getToxPublicKey() async -> String?
  
  /// Извлекает публичный ключ из адреса Tox.
  /// - Параметр address: Адрес Tox в виде строки (76 символов).
  /// - Возвращаемое значение: Строка с публичным ключом (64 символа) или `nil` при ошибке.
  func getToxPublicKey(from address: String) -> String?
  
  /// Метод для добавления нового друга по адресу. (Требует подтверждения)
  /// - Parameters:
  ///   - address: Адрес друга в сети Tox.
  ///   - message: Приветственное сообщение.
  /// - Returns: Номер друга, если добавление прошло успешно, иначе nil.
  func addFriend(address: String, message: String) async -> Int32?
  
  /// Метод для удаления друга по его публичному ключу.
  /// - Parameters:
  ///   - toxPublicKey: Публичный ключ друга.
  /// - Returns: true, если удаление прошло успешно, иначе false.
  func deleteFriend(toxPublicKey: String) async -> Bool
  
  /// Метод для получения номера друга по его публичному ключу.
  /// - Parameters:
  ///   - publicToxKey: Публичный ключ друга в сети Tox.
  /// - Returns: Номер друга, если он найден, иначе nil.
  func friendNumber(publicToxKey: String) async -> Int32?
  
  /// Метод для получения статуса подключения друга по его публичному ключу.
  /// - Parameters:
  ///   - toxPublicKey: Публичный ключ друга.
  /// - Returns: Статус подключения друга в виде значения перечисления `ConnectionToxStatus`, если он доступен, иначе nil.
  func friendConnectionStatus(toxPublicKey: String) async -> ConnectionToxStatus?
  
  /// Используя метод confirmFriendRequest, вы подтверждаете запрос на добавление в друзья, зная публичный ключ отправителя.
  /// Этот метод принимает публичный ключ друга и добавляет его в список друзей без отправки дополнительного сообщения.
  /// - Parameters:
  ///   - publicKey: Строка, представляющая публичный ключ друга. Этот ключ используется для идентификации пользователя в сети Tox.
  /// - Returns: Публичный ключ друга в сети Tox.
  func confirmFriendRequest(with publicToxKey: String) async -> String?
  
  /// Метод для отправки сообщения другу.
  /// - Parameters:
  ///   - toxPublicKey: Публичный ключ друга.
  ///   - message: Сообщение для отправки.
  ///   - messageType: Тип сообщения.
  /// - Returns: ID отправленного сообщения.
  func sendMessage(
    to toxPublicKey: String,
    message: String,
    messageType: ToxSendMessageType
  ) async throws -> Int32?
  
  /// Метод для установки статуса "печатает" для друга.
  /// - Parameters:
  ///   - isTyping: Статус "печатает" (true, если пользователь печатает).
  ///   - toxPublicKey: Публичный ключ друга.
  /// - Returns: Результат выполнения операции.
  func setUserIsTyping(_ isTyping: Bool, to toxPublicKey: String) async -> Result<Void, Error>
  
  /// Метод для установки статуса пользователя.
  func setSelfStatus(isOnline: Bool) async
  
  /// Запускает таймер для периодического вызова getFriendsStatus каждые 2 секунды.
  /// - Parameter completion: Замыкание, вызываемое с результатом получения статуса друзей.
  func startPeriodicFriendStatusCheck(completion: @escaping ([String: Bool]) -> Void) async
  
  /// Отправить файл с сообщением.
  /// - Parameters:
  ///   - toxPublicKey: Публичный ключ друга.
  ///   - recipientPublicKey: Публичный ключ получателя.
  ///   - model: Модель сообщения.
  ///   - recordModel: Модель записи (если имеется).
  ///   - files: Список URL файлов для отправки.
  func sendFile(
    toxPublicKey: String,
    recipientPublicKey: String,
    model: MessengerNetworkRequestDTO,
    recordModel: MessengeRecordingModel?,
    files: [URL]
  ) async
}
