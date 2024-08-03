//
//  IIncomingDataManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import Foundation

/// Протокол для управления входящими данными в приложении.
public protocol IIncomingDataManager: AnyObject {
  /// Событие при активации приложения.
  var onAppDidBecomeActive: (() -> Void)? { get set }
  
  /// Обновление статуса "в сети" текущего пользователя.
  /// - Parameter status: Новый статус пользователя.
  var onMyOnlineStatusUpdate: ((AppSettingsModel.Status) -> Void)? { get set }
  
  /// Получение сообщения.
  /// - Parameters:
  ///   - message: Модель сетевого запроса.
  ///   - messageID: Идентификатор сообщения.
  var onMessageReceived: ((MessengerNetworkRequestModel, Int32) -> Void)? { get set }
  
  /// Запрос на начало чата.
  /// - Parameters:
  ///   - request: Модель сетевого запроса.
  ///   - chatID: Идентификатор чата.
  var onRequestChat: ((MessengerNetworkRequestModel, String) -> Void)? { get set }
  
  /// Обновление статуса "в сети" друга.
  /// - Parameters:
  ///   - friendID: Идентификатор друга.
  ///   - status: Новый статус друга.
  var onFriendOnlineStatusUpdate: ((String, ContactModel.Status) -> Void)? { get set }
  
  /// Обновление статуса "печатает" друга.
  /// - Parameters:
  ///   - friendID: Идентификатор друга.
  ///   - isTyping: Статус "печатает".
  var onIsTypingFriendUpdate: ((String, Bool) -> Void)? { get set }
  
  /// Подтверждение прочтения сообщения другом.
  /// - Parameters:
  ///   - friendID: Идентификатор друга.
  ///   - messageID: Идентификатор сообщения.
  var onFriendReadReceipt: ((String, UInt32) -> Void)? { get set }
  
  /// Получение файла.
  /// - Parameters:
  ///   - friendID: Идентификатор друга.
  ///   - fileURL: URL файла.
  ///   - progress: Прогресс загрузки файла.
  var onFileReceive: ((String, URL, Double) -> Void)? { get set }
  
  /// Отправка файла.
  /// - Parameters:
  ///   - friendID: Идентификатор друга.
  ///   - progress: Прогресс отправки файла.
  ///   - fileName: Имя файла.
  var onFileSender: ((String, Double, String) -> Void)? { get set }
  
  /// Ошибка при отправке файла.
  /// - Parameters:
  ///   - friendID: Идентификатор друга.
  ///   - errorMessage: Сообщение об ошибке.
  var onFileErrorSender: ((String, String) -> Void)? { get set }
  
  /// Событие при создании скриншота.
  var onScreenshotTaken: (() -> Void)? { get set }
}
