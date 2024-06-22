//
//  ToxError.swift
//
//
//  Created by Vitalii Sosin on 09.06.2024.
//

import Foundation
import ToxCoreCpp

/// Перечисление ошибок Tox с комментариями на русском языке.
public enum ToxError: Error {
  /// Функция завершилась успешно.
  case ok
  
  /// Один из аргументов функции оказался NULL, что не было ожидаемо.
  case null
  
  /// Функция не смогла выделить достаточно памяти для хранения внутренних структур объекта Tox.
  case malloc
  
  /// Функция не смогла привязаться к порту. Это может означать, что все порты уже заняты, например, другими экземплярами Tox, или что возникла ошибка разрешений. Дополнительную информацию можно получить из errno.
  case portAlloc
  
  /// Значение proxy_type было недопустимым.
  case proxyBadType
  
  /// Значение proxy_type было допустимым, но формат proxy_host оказался недопустимым или был NULL.
  case proxyBadHost
  
  /// Значение proxy_type было допустимым, но значение proxy_port оказалось недопустимым.
  case proxyBadPort
  
  /// Указанный прокси-адрес не был найден.
  case proxyNotFound
  
  /// Переданный массив байтов содержал зашифрованное сохранение.
  case loadEncrypted
  
  /// Формат данных был недопустимым. Это может произойти при загрузке данных, сохранённых более старой версией Tox, или при повреждении данных. При загрузке из плохо отформатированных данных часть данных может быть загружена, а остальное отбрасывается. Передача недопустимого параметра длины также вызывает эту ошибку.
  case loadBadFormat
  
  /// Сообщение слишком длинное.
  case friendAddTooLong
  
  /// Отсутствует сообщение.
  case friendAddNoMessage
  
  /// Публичный ключ является собственным ключом.
  case friendAddOwnKey
  
  /// Запрос уже отправлен.
  case friendAddAlreadySent
  
  /// Неверная контрольная сумма.
  case friendAddBadChecksum
  
  /// Необходимо установить новый nospam.
  case friendAddSetNewNospam
  
  /// Неизвестная ошибка.
  case unknown
  
  /// Друг с указанным идентификатором не найден.
  /// Возникает, когда пытаетесь обратиться к другу, которого нет в списке друзей.
  case friendNotFound
  
  /// Друг не подключен.
  /// Возникает, когда друг, которому вы пытаетесь отправить сообщение, не находится в сети.
  case friendNotConnected
  
  /// Сообщение слишком длинное.
  /// Возникает, когда длина отправляемого сообщения превышает допустимый лимит.
  case messageTooLong
  
  /// Очередь отправки переполнена.
  /// Возникает, когда очередь отправки сообщений переполнена и нет возможности отправить новые сообщения.
  case sendQueueFull
  
  /// Нет точного совпадения.
  /// Возникает, когда ни один из переданных параметров не соответствует ожидаемому значению.
  /// Эта ошибка может возникнуть при использовании функции или метода, который требует точного соответствия параметров.
  case noExactMatches
  
  // Ошибки удаления друга
  /// Ошибка: Друг с указанным идентификатором не найден.
  case friendDeleteNotFound
  
  /// Ошибка: Не удалось удалить друга.
  case friendDeleteFailed
  
  // Ошибки запроса статуса друга
  /// Ошибка: Друг с указанным идентификатором не найден.
  case friendQueryFriendNotFound
  
  // Ошибки отправки файлов
  /// Ошибка: Друг с указанным идентификатором не найден.
  case fileSendFriendNotFound
  
  /// Ошибка: Имя файла слишком длинное.
  case fileNameTooLong
  
  /// Ошибка: Слишком много отправляемых файлов.
  case fileSendTooMany
  
  /// Ошибка: Друг не подключен.
  case fileSendFriendNotConnected
  
  /// Ошибка: Произошла ошибка при отправке файла.
  case fileSendError
  
  /// Ошибка: Произошла ошибка при отправке части файла.
  case fileSendChunkError
  
  /// Ошибка: Файл не найден.
  case fileChunkNotFound
  
  /// Ошибка: Файл не передается.
  case fileChunkNotTransferring
  
  /// Ошибка: Неверная длина данных.
  case fileChunkInvalidLength
  
  /// Ошибка: Очередь отправки переполнена.
  case fileChunkSendQueueFull
  
  /// Ошибка: Неверная позиция для отправки данных.
  case fileChunkWrongPosition
  
  /// Указан неверный номер друга.
  case invalidFriendNumber
  
  /// Сообщение пустое и не может быть отправлено.
  case messageEmpty
  
  /// Указан неверный номер конференции.
  case invalidConferenceNumber
  
  /// Конференция не подключена.
  case conferenceNotConnected
  
  /// Не удалось отправить сообщение.
  case failSend
  
  /// Никнейм слишком длинный.
  case nicknameTooLong
  
  /// Имя пользователя пустое и должно быть задано.
  case emptyUserName
  
  /// Неверная кодировка строки.
  case invalidStringEncoding
  
  /// Имя друга пустое.
  case emptyFriendName
  
  /// Статусное сообщение пустое.
  case emptyStatusMessage
  
  /// Статусное сообщение друга пустое.
  case emptyFriendStatusMessage
}

extension ToxError {
  /// Инициализация ToxError из значения C-перечисления Tox_Err_New.
  /// - Parameter cError: Значение C-перечисления Tox_Err_New.
  public init(cError: Tox_Err_New) {
    switch cError {
    case TOX_ERR_NEW_OK:
      self = .ok
    case TOX_ERR_NEW_NULL:
      self = .null
    case TOX_ERR_NEW_MALLOC:
      self = .malloc
    case TOX_ERR_NEW_PORT_ALLOC:
      self = .portAlloc
    case TOX_ERR_NEW_PROXY_BAD_TYPE:
      self = .proxyBadType
    case TOX_ERR_NEW_PROXY_BAD_HOST:
      self = .proxyBadHost
    case TOX_ERR_NEW_PROXY_BAD_PORT:
      self = .proxyBadPort
    case TOX_ERR_NEW_PROXY_NOT_FOUND:
      self = .proxyNotFound
    case TOX_ERR_NEW_LOAD_ENCRYPTED:
      self = .loadEncrypted
    case TOX_ERR_NEW_LOAD_BAD_FORMAT:
      self = .loadBadFormat
    default:
      self = .unknown
    }
  }
  
  /// Инициализация ToxError из значения C-перечисления TOX_ERR_FRIEND_ADD.
  /// - Parameter friendAddError: Значение C-перечисления TOX_ERR_FRIEND_ADD.
  public init(friendAddError: TOX_ERR_FRIEND_ADD) {
    switch friendAddError {
    case TOX_ERR_FRIEND_ADD_OK:
      self = .ok
    case TOX_ERR_FRIEND_ADD_NULL:
      self = .null
    case TOX_ERR_FRIEND_ADD_TOO_LONG:
      self = .friendAddTooLong
    case TOX_ERR_FRIEND_ADD_NO_MESSAGE:
      self = .friendAddNoMessage
    case TOX_ERR_FRIEND_ADD_OWN_KEY:
      self = .friendAddOwnKey
    case TOX_ERR_FRIEND_ADD_ALREADY_SENT:
      self = .friendAddAlreadySent
    case TOX_ERR_FRIEND_ADD_BAD_CHECKSUM:
      self = .friendAddBadChecksum
    case TOX_ERR_FRIEND_ADD_SET_NEW_NOSPAM:
      self = .friendAddSetNewNospam
    case TOX_ERR_FRIEND_ADD_MALLOC:
      self = .malloc
    default:
      self = .unknown
    }
  }
  
  /// Инициализация ToxError из значения C-перечисления TOX_ERR_FRIEND_BY_PUBLIC_KEY.
  /// - Parameter friendByPublicKeyError: Значение C-перечисления TOX_ERR_FRIEND_BY_PUBLIC_KEY.
  public init(friendByPublicKeyError: TOX_ERR_FRIEND_BY_PUBLIC_KEY) {
    switch friendByPublicKeyError {
    case TOX_ERR_FRIEND_BY_PUBLIC_KEY_OK:
      self = .ok
    case TOX_ERR_FRIEND_BY_PUBLIC_KEY_NULL:
      self = .null
    case TOX_ERR_FRIEND_BY_PUBLIC_KEY_NOT_FOUND:
      self = .unknown
    default:
      self = .unknown
    }
  }
  
  /// Инициализатор для ошибок удаления друга.
  /// - Parameter friendDeleteError: Значение ошибки C-перечисления TOX_ERR_FRIEND_DELETE.
  public init(friendDeleteError: TOX_ERR_FRIEND_DELETE) {
    switch friendDeleteError {
    case TOX_ERR_FRIEND_DELETE_OK:
      self = .friendDeleteNotFound
    default:
      self = .unknown
    }
  }
  
  /// Инициализатор для ошибок запроса статуса друга.
  /// - Parameter friendQueryError: Значение ошибки C-перечисления TOX_ERR_FRIEND_QUERY.
  public init(friendQueryError: TOX_ERR_FRIEND_QUERY) {
    switch friendQueryError {
    case TOX_ERR_FRIEND_QUERY_OK:
      self = .unknown
    case TOX_ERR_FRIEND_QUERY_FRIEND_NOT_FOUND:
      self = .friendQueryFriendNotFound
    default:
      self = .unknown
    }
  }
  
  /// Инициализатор для ошибок отправки файлов.
  /// - Parameter fileSendError: Значение ошибки C-перечисления TOX_ERR_FILE_SEND.
  public init(fileSendError: TOX_ERR_FILE_SEND) {
    switch fileSendError {
    case TOX_ERR_FILE_SEND_OK:
      self = .unknown
    case TOX_ERR_FILE_SEND_FRIEND_NOT_FOUND:
      self = .fileSendFriendNotFound
    case TOX_ERR_FILE_SEND_NAME_TOO_LONG:
      self = .fileNameTooLong
    case TOX_ERR_FILE_SEND_TOO_MANY:
      self = .fileSendTooMany
    case TOX_ERR_FILE_SEND_FRIEND_NOT_CONNECTED:
      self = .fileSendFriendNotConnected
    default:
      self = .unknown
    }
  }
  
  /// Инициализатор для ошибок отправки части файла.
  /// - Parameter fileSendChunkError: Значение ошибки C-перечисления TOX_ERR_FILE_SEND_CHUNK.
  public init(fileSendChunkError: TOX_ERR_FILE_SEND_CHUNK) {
    switch fileSendChunkError {
    case TOX_ERR_FILE_SEND_CHUNK_OK:
      self = .unknown
    case TOX_ERR_FILE_SEND_CHUNK_FRIEND_NOT_FOUND:
      self = .fileSendFriendNotFound
    case TOX_ERR_FILE_SEND_CHUNK_FRIEND_NOT_CONNECTED:
      self = .fileSendFriendNotConnected
    case TOX_ERR_FILE_SEND_CHUNK_NOT_FOUND:
      self = .fileChunkNotFound
    case TOX_ERR_FILE_SEND_CHUNK_NOT_TRANSFERRING:
      self = .fileChunkNotTransferring
    case TOX_ERR_FILE_SEND_CHUNK_INVALID_LENGTH:
      self = .fileChunkInvalidLength
    case TOX_ERR_FILE_SEND_CHUNK_SENDQ:
      self = .fileChunkSendQueueFull
    case TOX_ERR_FILE_SEND_CHUNK_WRONG_POSITION:
      self = .fileChunkWrongPosition
    default:
      self = .unknown
    }
  }
  
  // Инициализация ToxError из значения C-перечисления TOX_ERR_FRIEND_SEND_MESSAGE.
  /// - Parameter messageSendError: Значение C-перечисления TOX_ERR_FRIEND_SEND_MESSAGE.
  init(cError: TOX_ERR_FRIEND_SEND_MESSAGE) {
    switch cError {
    case TOX_ERR_FRIEND_SEND_MESSAGE_FRIEND_NOT_FOUND:
      self = .invalidFriendNumber
    case TOX_ERR_FRIEND_SEND_MESSAGE_FRIEND_NOT_CONNECTED:
      self = .friendNotConnected
    case TOX_ERR_FRIEND_SEND_MESSAGE_SENDQ:
      self = .sendQueueFull
    case TOX_ERR_FRIEND_SEND_MESSAGE_TOO_LONG:
      self = .messageTooLong
    case TOX_ERR_FRIEND_SEND_MESSAGE_EMPTY:
      self = .messageEmpty
    default:
      self = .unknown
    }
  }
  
  init(conferenceError: TOX_ERR_CONFERENCE_SEND_MESSAGE) {
    switch conferenceError {
    case TOX_ERR_CONFERENCE_SEND_MESSAGE_CONFERENCE_NOT_FOUND:
      self = .invalidConferenceNumber
    case TOX_ERR_CONFERENCE_SEND_MESSAGE_NO_CONNECTION:
      self = .conferenceNotConnected
    case TOX_ERR_CONFERENCE_SEND_MESSAGE_TOO_LONG:
      self = .messageTooLong
    case TOX_ERR_CONFERENCE_SEND_MESSAGE_FAIL_SEND:
      self = .failSend
    default:
      self = .unknown
    }
  }
  
  init(setInfoError: TOX_ERR_SET_INFO) {
    switch setInfoError {
    case TOX_ERR_SET_INFO_NULL:
      self = .null
    case TOX_ERR_SET_INFO_TOO_LONG:
      self = .nicknameTooLong
    default:
      self = .unknown
    }
  }
  
  init(setTypingError: TOX_ERR_SET_TYPING) {
    switch setTypingError {
    case TOX_ERR_SET_TYPING_FRIEND_NOT_FOUND:
      self = .friendNotFound
    default:
      self = .unknown
    }
  }
}
