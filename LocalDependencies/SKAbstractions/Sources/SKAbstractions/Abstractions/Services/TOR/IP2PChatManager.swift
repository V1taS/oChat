//
//  IP2PChatManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.06.2024.
//

import Foundation

/// Протокол управления чатом P2P через Tor.
public protocol IP2PChatManager {
  func start(
    saveDataString: String?,
    completion: ((Result<Void, Error>) -> Void)?
  )
  
  /// Строка, содержащая сохранённое состояние Tox в формате Base64
  func toxStateAsString(completion: ((_ stateAsString: String?) -> Void)?)
  
  /// Получить адрес Tox и возвращает результат через завершение.
  /// - Parameter completion: Блок завершения, который возвращает результат генерации адреса.
  func getToxAddress(completion: @escaping (Result<String, Error>) -> Void)
  
  /// Метод для получения публичного ключа.
  /// - Returns: Публичный ключ в виде строки в шестнадцатеричном формате.
  func getToxPublicKey(completion: @escaping (String?) -> Void)
  
  /// Извлекает публичный ключ из адреса Tox.
  /// - Параметр address: Адрес Tox в виде строки (76 символов).
  /// - Возвращаемое значение: Строка с публичным ключом (64 символа) или `nil` при ошибке.
  func getToxPublicKey(from address: String) -> String?
  
  /// Метод для добавления нового друга по адресу. (Требует подтверждения)
  /// - Parameters:
  ///   - address: Адрес друга в сети Tox.
  ///   - message: Приветственное сообщение.
  /// - Returns: Номер друга, если добавление прошло успешно, иначе nil.
  func addFriend(address: String, message: String, completion: ((_ contactID: Int32?) -> Void)?)
  
  /// Метод для удаления друга по его номеру.
  /// - Parameters:
  ///   - toxPublicKey: Публичный ключ друга
  /// - Returns: true, если удаление прошло успешно, иначе false.
  func deleteFriend(toxPublicKey: String, completion: ((Bool) -> Void)?)
  
  /// Метод для получения номера друга по его публичному ключу.
  /// - Parameters:
  ///   - publicToxKey: Публичный ключ друга в сети Tox.
  /// - Returns: Номер друга, если он найден, иначе nil.
  func friendNumber(publicToxKey: String, completion: ((_ contactID: Int32?) -> Void)?)
  
  /// Метод для получения статуса подключения друга по его номеру.
  /// - Parameters:
  ///   - toxPublicKey: Публичный ключ друга
  /// - Returns: Статус подключения друга в виде значения перечисления `ConnectionToxStatus`, если он доступен, иначе nil.
  func friendConnectionStatus(toxPublicKey: String, completion: ((ConnectionToxStatus?) -> Void)?)
  
  /// Используя метод confirmFriendRequest, вы подтверждаете запрос на добавление в друзья, зная публичный ключ отправителя.
  /// Этот метод принимает публичный ключ друга и добавляет его в список друзей без отправки дополнительного сообщения.
  /// - Parameters:
  ///   - publicKey: Строка, представляющая публичный ключ друга. Этот ключ используется для идентификации пользователя в сети Tox.
  ///   - completion: Замыкание, вызываемое после завершения операции. Возвращает результат выполнения в виде:
  ///   - publicToxKey: Публичный ключ друга в сети Tox.
  ///   - ToxError: Ошибка, если запрос не удалось подтвердить.
  func confirmFriendRequest(
    with publicToxKey: String,
    completion: @escaping (Result<String, Error>) -> Void
  )
  
  /// Метод для отправки сообщения другу.
  /// - Parameters:
  ///   - toxPublicKey: Публичный ключ друга
  ///   - message: Сообщение для отправки.
  ///   - messageType: Тип сообщения.
  ///   - completion: Замыкание, вызываемое по завершении операции, с результатом успешной отправки или ошибкой.
  func sendMessage(
    to toxPublicKey: String,
    message: String,
    messageType: ToxSendMessageType,
    completion: @escaping (Result<Int32, Error>) -> Void
  )
  
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
  
  /// Запускает таймер для периодического вызова getFriendsStatus каждые 2 секунды.
  func startPeriodicFriendStatusCheck(completion: (([String: Bool]) -> Void)?)
  
  /// Отправить файл с сообщением
  func sendFile(
    toxPublicKey: String,
    recipientPublicKey: String,
    model: MessengerNetworkRequestDTO,
    recordModel: MessengeRecordingModel?,
    files: [URL]
  )
}
