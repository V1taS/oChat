//
//  ToxServiceProtocol.swift
//  ToxSwift
//
//  Created by Vitalii Sosin on 7.05.2025.
//

import Foundation
import CTox
import CSodium

/// Протокол публичного API Tox-сервиса.
public protocol ToxServiceProtocol {

  // MARK: — Инициализация

  /// Создаёт и инициализирует сервис Tox с заданными опциями и bootstrap-узлами.
  init(options: ToxServiceOptions, bootstrapNodes: [ToxNode]) throws

  // MARK: — Статус пользователя

  /// Установить статус пользователя
  func setUserStatus(_ status: UserStatus) async

  /// Получить статус пользователя
  func getUserStatus() async -> UserStatus

  // MARK: — Основная информация о пользователе

  /// Возвращает Tox-адрес пользователя (38-байтовая строка).
  func getOwnAddress() async -> String

  /// Возвращает публичный ключ пользователя.
  func getOwnPublicKey() async -> Data

  /// Возвращает секретный ключ пользователя.
  func getOwnSecretKey() async -> Data

  // MARK: — Профиль пользователя

  /// Устанавливает отображаемое имя.
  func setDisplayName(_ name: String) async throws

  /// Возвращает отображаемое имя.
  func getDisplayName() async -> String

  /// Устанавливает статус-сообщение пользователя.
  func setStatusMessage(_ message: String) async throws


  // MARK: — Друзья и сообщения

  /// Добавляет друга по публичному ключу с приветствием.
  /// - Returns: ID добавленного друга.
  func addFriend(withAddress address: Data, greeting message: String) async throws -> UInt32

  /// Возвращает публичный адрес (64-символьный hex PK) друга по его ID.
  func getFriendAddress(_ friendID: UInt32) async -> String

  /// Принимает входящий запрос дружбы.
  /// publicKey – 32 raw-byte, возвращает friendID.
  func acceptFriendRequest(publicKey: Data) async throws -> UInt32

  /// Удаляет друга по идентификатору.
  func removeFriend(withID friendID: UInt32) async throws

  /// Отправляет текстовое сообщение другу.
  func sendMessage(
    toFriend friendID: UInt32,
    text: String
  ) async throws -> UInt32

  /// Возвращает статус подключения друга.
  func getFriendConnectionStatus(forID friendID: UInt32) async -> ToxConnectionState

  /// Возвращает имя друга.
  func getFriendName(_ friendID: UInt32) async -> String

  /// Возвращает статус-сообщение друга.
  func getFriendStatusMessage(_ friendID: UInt32) async -> String

  /// Возвращает публичный ключ друга.
  func getFriendPublicKey(_ friendID: UInt32) async -> Data

  /// Возвращает текущий пользовательский статус друга.
  func getFriendUserStatus(_ friendID: UInt32) async -> UserStatus

  /// Возвращает тайм-стемп последнего онлайна (Unix-время).
  func getFriendLastOnline(_ friendID: UInt32) async -> UInt64

  /// Проверяет, существует ли друг с данным ID.
  func friendExists(_ friendID: UInt32) async -> Bool

  /// Возвращает список всех ID друзей.
  func friendList() async -> [UInt32]


  // MARK: — Передача файлов

  /// Инициирует отправку файла другу.
  /// - Returns: ID создаваемой передачи.
  func sendFile(toFriend friendID: UInt32,
                size: UInt64,
                fileName: String) async throws -> UInt32

  /// Отправляет часть файла другу.
  func sendFileChunk(toFriend friendID: UInt32,
                     fileID: UInt32,
                     position: UInt64,
                     data: Data) async throws

  /// Управляет передачей файла (пауза, отмена, возобновление).
  func controlFile(toFriend friendID: UInt32,
                   fileID: UInt32,
                   control: FileControl) async throws

  /// Перемещает указатель чтения/записи в рамках передаваемого файла.
  func seekFile(toFriend friendID: UInt32,
                fileID: UInt32,
                position: UInt64) async throws

  /// Получает ID активного файла по индексу (или nil, если нет).
  func getFileID(ofFriend friendID: UInt32,
                 at index: UInt32) async -> UInt32?


  // MARK: — Конференции (групповые чаты)

  /// Создаёт новую конференцию.
  /// - Returns: ID конференции.
  func createConference() async throws -> UInt32

  /// Отправляет сообщение в конференции.
  func sendMessage(inConference conferenceID: UInt32,
                   text: String,
                   type: MessageKind) async throws

  /// Возвращает **имя конкретного пира**.
  func getConferencePeerName(_ conferenceID: UInt32,
                             peerID: UInt32) async -> String

  /// Приглашает друга в конференцию.
  func inviteToConference(friendID: UInt32,
                          conferenceID: UInt32) async throws

  /// Присоединяется к конференции по «cookie» из приглашения.
  /// - Returns: Локальный ID созданной конференции.
  func joinConference(fromFriend friendID: UInt32,
                      cookie: Data) async throws -> UInt32

  /// Покидает конференцию.
  func leaveConference(_ conferenceID: UInt32,
                       partingMessage: String?) async throws

  /// Возвращает список всех конференций.
  func conferenceList() async -> [UInt32]

  /// Возвращает заголовок конференции.
  func getConferenceTitle(_ conferenceID: UInt32) async -> String

  /// Устанавливает заголовок конференции.
  func setConferenceTitle(_ conferenceID: UInt32,
                          title: String) async throws

  /// Возвращает тип конференции (классический / текст-только).
  func getConferenceType(_ conferenceID: UInt32) async -> ConferenceType


  // MARK: — Потоки событий

  /// Входящие текстовые сообщения.
  var incomingMessages: AsyncStream<IncomingMessage> { get async }

  /// События по передаче файлов.
  var fileEvents: AsyncStream<FileEvent> { get async }

  /// События звонков (ToxAV).
  var callEvents: AsyncStream<CallEvent> { get async }

  /// События друзей (добавление, изменение статуса и т. д.).
  var friendEvents: AsyncStream<FriendEvent> { get async }

  /// События конференций.
  var conferenceEvents: AsyncStream<ConferenceEvent> { get async }

  /// Публичный стрим статуса DHT-подключения к сети Tox
  var connectionStatusEvents: AsyncStream<ToxConnectionState> { get async }


  // MARK: — Аудио/Видео (ToxAV)

  /// Инициирует исходящий звонок.
  func startCall(friendID: UInt32,
                 audioBitRate: UInt32,
                 videoBitRate: UInt32) async throws

  /// Принимает входящий звонок.
  func answerCall(friendID: UInt32,
                  audioBitRate: UInt32,
                  videoBitRate: UInt32) async throws

  /// Управляет активным звонком (пауза, возобновление и т. д.).
  func controlCall(friendID: UInt32,
                   control: CallControl) async throws

  /// Отправляет аудио-фрейм PCM-16 LE.
  func sendAudioFrame(friendID: UInt32,
                      pcm: Data,
                      sampleCount: UInt32,
                      channels: UInt8,
                      sampleRate: UInt32) async throws

  /// Отправляет видео-фрейм YUV 420 planar.
  func sendVideoFrame(friendID: UInt32,
                      width: UInt16,
                      height: UInt16,
                      y: Data,
                      u: Data,
                      v: Data) async throws


  // MARK: — Резервное копирование и восстановление

  /// Экспорт полного состояния (друзья, конференции, ключи и т. д.).
  func exportSavedata() async -> Data

  /// Корректно останавливает ядро (можно звать при уходе в бэкграунд)
  func shutdown() async

  /// Полный перезапуск с сохранением профиля
  func restart() async throws


  // MARK: — Версия и совместимость

  /// Текущая версия библиотеки toxcore.
  static var libraryVersion: (major: UInt32, minor: UInt32, patch: UInt32) { get }

  /// Проверяет, совместима ли указанная версия toxcore с текущей.
  static func isCompatible(major: UInt32,
                           minor: UInt32,
                           patch: UInt32) -> Bool
}
