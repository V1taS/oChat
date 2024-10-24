//
//  MessengeModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 05.06.2024.
//

import Foundation

public typealias MessengeModels = [String: [MessengeModel]]

/// Модель сообщения для чата.
public struct MessengeModel {
  /// Уникальный идентификатор сообщения.
  public let id: String
  /// Временный ID Сообщения
  public var tempMessageID: UInt32?
  /// Тип сообщения (отправленное или полученное).
  public let messageType: MessageType
  /// Статус доставки и чтения сообщения.
  public var messageStatus: MessageStatus
  /// Текст сообщения.
  public var message: String
  /// Дата отправки сообщения
  public let date: Date
  /// Цитируемое сообщение
  public var replyMessageText: String?
  /// Массив изображений сообщения
  public var images: [MessengeImageModel]
  /// Массив видео сообщения
  public var videos: [MessengeVideoModel]
  /// Запись сообщения (опционально)
  public var recording: MessengeRecordingModel?
  
  /// Инициализирует новый экземпляр сообщения.
  /// - Parameters:
  ///   - messageType: Тип сообщения (отправленное или полученное).
  ///   - messageStatus: Статус доставки и чтения сообщения.
  ///   - message: Текст сообщения.
  ///   - replyMessageID: Ответ на сообщение
  ///   - images: Изображения
  ///   - videos: Видео
  ///   - recording: Аудиозапись
  public init(
    messageType: MessageType,
    messageStatus: MessageStatus,
    message: String,
    replyMessageText: String?,
    images: [MessengeImageModel],
    videos: [MessengeVideoModel],
    recording: MessengeRecordingModel?
  ) {
    self.messageType = messageType
    self.messageStatus = messageStatus
    self.message = message
    self.replyMessageText = replyMessageText
    self.images = images
    self.videos = videos
    self.recording = recording
    self.id = UUID().uuidString
    self.date = Date()
  }
}

// MARK: - MessengeType

extension MessengeModel {
  /// Перечисление типов сообщений в чате.
  public enum MessageType {
    /// Сообщение отправлено мною
    case own
    /// Сообщение получено от другого пользователя.
    case received
    /// Системное сообщение Успех
    case systemSuccess
    /// Системное сообщение Внимание
    case systemAttention
    /// Системное сообщение Опасность
    case systemDanger
    
    /// Системное сообщение
    public var isSystem: Bool {
      switch self {
      case .systemSuccess, .systemAttention, .systemDanger:
        return true
      default:
        return false
      }
    }
  }
}

// MARK: - MessengeType

extension MessengeModel {
  /// Перечисление, представляющее статусы сообщений
  public enum MessageStatus {
    /// Статус отправки сообщения.
    /// Указывает, что сообщение в процессе отправки.
    case sending
    
    /// Статус ошибки отправки сообщения.
    /// Указывает, что произошла ошибка при отправке сообщения.
    case failed
    
    /// Статус успешной отправки сообщения.
    /// Указывает, что сообщение было успешно отправлено.
    case sent
  }
}

// MARK: - IdentifiableAndCodable

extension MessengeModel: IdentifiableAndCodable {}
extension MessengeModel.MessageType: IdentifiableAndCodable {}
extension MessengeModel.MessageStatus: IdentifiableAndCodable {}
