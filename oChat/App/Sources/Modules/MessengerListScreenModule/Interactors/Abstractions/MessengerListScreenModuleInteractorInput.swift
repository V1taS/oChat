//
//  MessengerListScreenModuleInteractorInput.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.08.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKAbstractions
import SKStyle
import AVFoundation
import SKManagers

/// События которые отправляем от Presenter к Interactor
protocol MessengerListScreenModuleInteractorInput {
  // CryptoManager
  /// Расшифровывает данные, используя приватный ключ.
  /// - Parameters:
  ///   - encryptedText: Зашифрованные данные.
  /// - Returns: Расшифрованные данные.
  func decrypt(_ encryptedText: String?) async -> String?
  
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
  /// - Returns: Расшифрованные данные в виде объекта Data.
  func decrypt(_ encryptedData: Data?) async -> Data?
  
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
  
  // ToxManager
  /// Извлекает публичный ключ из адреса Tox.
  /// - Параметр address: Адрес Tox в виде строки (76 символов).
  /// - Возвращаемое значение: Строка с публичным ключом (64 символа) или `nil` при ошибке.
  func getToxPublicKey(from address: String) -> String?
  
  /// Получает адрес onion-сервиса.
  /// - Returns: Адрес сервиса или ошибка.
  func getToxAddress() async -> String?
  
  /// Метод для получения публичного ключа.
  /// - Returns: Публичный ключ в виде строки в шестнадцатеричном формате.
  func getToxPublicKey() async -> String?
  
  /// Используя метод confirmFriendRequest, вы подтверждаете запрос на добавление в друзья, зная публичный ключ отправителя.
  /// Этот метод принимает публичный ключ друга и добавляет его в список друзей без отправки дополнительного сообщения.
  /// - Parameters:
  ///   - publicKey: Строка, представляющая публичный ключ друга. Этот ключ используется для идентификации пользователя в сети Tox.
  ///   - return: Возвращает результат выполнения в виде:
  func confirmFriendRequest(with publicToxKey: String) async -> String?
  
  /// Метод для установки статуса пользователя.
  func setSelfStatus(isOnline: Bool) async
  
  /// Метод для установки статуса "печатает" для друга.
  /// - Parameters:
  ///   - isTyping: Статус "печатает" (true, если пользователь печатает).
  ///   - toxPublicKey: Публичный ключ друга
  ///   - return: Результат успешного выполнения или ошибки.
  func setUserIsTyping(_ isTyping: Bool, to toxPublicKey: String) async -> Result<Void, Error>
  
  /// Запускает таймер для периодического вызова getFriendsStatus каждые 2 секунды.
  func startPeriodicFriendStatusCheck(completion: (() -> Void)?) async
  
  /// Запуск TOX сервисы
  func stratTOXService() async
  
  // ContactManager
  /// Получает массив моделей контактов `ContactModel` асинхронно.
  func getContactModels() async -> [ContactModel]
  
  /// Сохраняет `ContactModel` асинхронно.
  /// - Parameters:
  ///   - model: Модель `ContactModel`, которая будутет сохранена.
  func saveContactModel(_ model: ContactModel) async
  
  /// Удаляет модель контакта `ContactModel` асинхронно.
  /// - Parameters:
  ///   - contactModel: Модель `ContactModel`, которая будет удалена.
  ///   - return: Завершение, которое вызывается после завершения операции удаления
  @discardableResult
  func removeContactModels(_ contactModel: ContactModel) async -> Bool
  
  /// Получить контакт по адресу
  func getContactModelsFrom(toxAddress: String) async -> ContactModel?
  
  /// Получить контакт по публичному ключу
  func getContactModelsFrom(toxPublicKey: String) async -> ContactModel?
  
  /// Устанавливает, является ли контакт онлайн
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - status: Значение, указывающее, является ли контакт онлайн
  func setStatus(_ model: ContactModel, _ status: ContactModel.Status) async
  
  /// Переводит всех контактов в состояние оффлайн.
  func setAllContactsIsOffline() async
  
  /// Переводит всех контактов в состояние Не Печатают
  func setAllContactsNoTyping() async
  
  /// Очищает все временные ИДишники
  func clearAllMessengeTempID() async
  
  // SettingsManager
  /// Получить модель со всеми настройками
  func getAppSettingsModel() async -> AppSettingsModel
  
  /// Проверяем установлен ли пароль на телефоне, это необходимо для шифрования данных
  func passcodeNotSetInSystemIOSheck() async
  
  // NotificationManager
  /// Метод для отправки push-уведомлений
  func sendPushNotification(contact: ContactModel) async
  
  /// Запрос доступа к Уведомлениям
  /// - Parameter granted: Булево значение, указывающее, было ли предоставлено разрешение
  @discardableResult
  func requestNotification() async -> Bool
  
  /// Метод для проверки, включены ли уведомления
  /// - Parameter enabled: Булево значение, указывающее, было ли включено уведомление
  func isNotificationsEnabled() async -> Bool
  
  /// Сохраняет токен для пуш сообщений
  /// - Parameters:
  ///   - token: Токен для пуш сообщений
  func saveMyPushNotificationToken(_ token: String) async
  
  /// Получить токен для пушей
  func getPushNotificationToken() async -> String?
  
  // FileManager
  /// Получить имя файла по URL без расширения
  func getFileNameWithoutExtension(from url: URL) -> String
  
  /// Получить имя файла по URL
  func getFileName(from url: URL) -> String?
  
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
  
  /// Получить кадр первой секунлы из видео
  func getFirstFrame(from url: URL) -> Data?
  
  /// Делаем маленькое изображение
  func resizeThumbnailImageWithFrame(data: Data) -> Data?
  
  /// Метод для разархивирования файлов
  func receiveAndUnzipFile(
    zipFileURL: URL,
    password: String
  ) async throws -> (model: MessengerNetworkRequestModel, recordingDTO: MessengeRecordingDTO?, files: [URL])
  
  // MessageManager
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
  
  /// Отправить файл с сообщением
  func sendFile(
    toxPublicKey: String,
    recipientPublicKey: String,
    recordModel: MessengeRecordingModel?,
    messengerRequest: MessengerNetworkRequestModel,
    files: [URL]
  ) async
  
  // InterfaceManager
  /// Установить красную точку на таб баре
  func setRedDotToTabBar(value: String?)
  
  // SystemService
  /// Возвращает уникальный идентификатор устройства.
  func getDeviceIdentifier() -> String
  
  // DeepLinkService
  /// Получает адрес глубокой ссылки.
  /// - Parameter return: Результат в виде строки или nil, если адрес не найден.
  func getDeepLinkAdress() async -> String?
  
  /// Удаляет URL глубокой ссылки.
  func deleteDeepLinkURL()
  
  // NotificationService (Directly accessed)
  /// Показать уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  func showNotification(_ type: NotificationServiceType)
  
  // ModelHandlerService (Directly accessed)
  /// Получает модель `MessengerModel` асинхронно.
  func getMessengerModel() async -> MessengerModel
  
  /// Возвращает текущий язык приложения.
  func getCurrentLanguage() -> AppLanguageType
  
  /// Делегат, через который интерактор передает события презентеру.
  /// Используется для уведомления презентера о завершении асинхронных операций или изменениях состояния.
  ///
  /// - Note: Устанавливается при создании модуля и не изменяется в течение жизненного цикла модуля.
  var output: MessengerListScreenModuleInteractorOutput? { get set }
}
