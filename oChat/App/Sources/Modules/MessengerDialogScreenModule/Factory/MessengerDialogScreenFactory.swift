//
//  MessengerDialogScreenFactory.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions
import ExyteChat

/// Cобытия которые отправляем из Factory в Presenter
protocol MessengerDialogScreenFactoryOutput: AnyObject {
  /// Пользователь выбрал повторить отправку сообщения
  func userSelectRetryAction(_ model: MessengeModel) async
  /// Пользователь выбрал удалить сообщение
  func userSelectDeleteAction(_ model: MessengeModel) async
  /// Пользователь выбрал скопировать сообщение
  func userSelectCopyAction(_ model: MessengeModel) async
}

/// Cобытия которые отправляем от Presenter к Factory
protocol MessengerDialogScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitleFrom(_ adress: String) -> String
  
  /// Создать плейсхолдер при добавлении контакта
  func createInitialPlaceholder() -> String
  
  /// Создать основной плейсхолдер
  func createMainPlaceholder() -> String
  
  /// Создать Initial контакт
  func createInitialContact(address: String) -> ContactModel
  
  /// Создать модель данных для запроса на переписку
  func createInitialHintModel() -> MessengerDialogHintModel
  
  /// Создать модель данных когда получил запрос на переписку
  func createRequestHintModel() -> MessengerDialogHintModel
  
  /// Создать заголовок для кнопки отмена запроса на переписку
  func createRequestButtonCancelTitle() -> String
  
  /// Создаем модели для отображения
  func createMessageModels(
    models: [MessengeModel],
    contactModel: ContactModel
  ) -> [Message]
  
  /// Получить количество сообщений исходя из максимального допустимого количества показа на экране
  func loadMessage(
    before: Message?,
    messengeModels: [Message],
    showMessengeMaxCount: Int
  ) -> [Message]
}

/// Фабрика
final class MessengerDialogScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: MessengerDialogScreenFactoryOutput?
}

// MARK: - MessengerDialogScreenFactoryInput

extension MessengerDialogScreenFactory: MessengerDialogScreenFactoryInput {
  func loadMessage(
    before: Message?,
    messengeModels: [Message],
    showMessengeMaxCount: Int
  ) -> [Message] {
    // Если `before` равно nil, берем сообщения с самого начала
    guard let before = before else {
      // Проверка границ диапазона
      let endIndex = min(showMessengeMaxCount, messengeModels.count)
      return Array(messengeModels.prefix(endIndex))
    }
    
    // Найти индекс сообщения `before`
    guard let beforeIndex = messengeModels.firstIndex(where: { $0.id == before.id }) else {
      // Если сообщение не найдено, возвращаем пустой массив или обрабатываем ошибку
      return []
    }
    
    // Проверка на валидность индекса
    guard beforeIndex < messengeModels.count else {
      return []
    }
    
    // Получаем сообщения до и включая `before`
    let previousMessages = Array(messengeModels[beforeIndex...])
    
    // Проверка границ диапазона
    let endIndex = min(beforeIndex + showMessengeMaxCount, messengeModels.count)
    let nextMessages = Array(messengeModels[beforeIndex..<endIndex])
    
    // Объединяем оба массива
    return nextMessages + previousMessages
  }
  
  func createMessageModels(
    models: [MessengeModel],
    contactModel: ContactModel
  ) -> [Message] {
    // Создаем объект User
    let user = User(
      id: contactModel.id,
      name: (contactModel.name ?? contactModel.toxAddress?.formatString(minTextLength: 10)) ?? "",
      avatarURL: nil,
      isCurrentUser: false
    )
    
    return models.map { model in
      let status: Message.Status
      var replyMessage: ReplyMessage?
      
      switch model.messageStatus {
      case .sending:
        status = .sending
      case .failed:
        status = .error
      case .sent:
        status = .sent
      }
      
      // Находим сообщение для ответа, если оно есть
      if let replyMessageText = model.replyMessageText {
        replyMessage = ReplyMessage(
          id: UUID().uuidString,
          user: user.copy(isCurrentUser: model.messageType == .own),
          text: replyMessageText,
          attachments: [],
          recording: nil
        )
      }
      
      return Message(
        id: model.id,
        user: user.copy(isCurrentUser: model.messageType == .own),
        status: status,
        createdAt: model.date,
        isSystemMessage: model.messageType.isSystem,
        text: model.message,
        attachments: model.images.compactMap { $0.mapTo() } + model.videos.compactMap { $0.mapTo() },
        recording: model.recording?.mapTo(),
        replyMessage: replyMessage,
        retryAction: { [weak self] _ in
          Task { [weak self] in
            guard let self else { return }
            await output?.userSelectRetryAction(model)
          }
        },
        deleteAction: { [weak self] _ in
          Task { [weak self] in
            guard let self else { return }
            await output?.userSelectDeleteAction(model)
          }
        },
        copyAction: { [weak self] _ in
          Task { [weak self] in
            guard let self else { return }
            await output?.userSelectCopyAction(model)
          }
        }
      )
    }
  }
  
  func createRequestButtonCancelTitle() -> String {
    OChatStrings.MessengerDialogScreenLocalization.Messenger
      .Request.Button.Cancel.title
  }
  
  func createRequestHintModel() -> MessengerDialogHintModel {
    return MessengerDialogHintModel(
      lottieAnimationName: nil,
      headerTitle: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Request.Header.title,
      headerDescription: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Request.Header.description,
      buttonTitle: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Request.Button.title,
      oneTitle: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Request.One.title,
      oneDescription: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Request.One.description,
      oneSystemImageName: "envelope.fill",
      twoTitle: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Request.Two.title,
      twoDescription: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Request.Two.description,
      twoSystemImageName: "shield.fill",
      threeTitle: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Request.Three.title,
      threeDescription: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Request.Three.description,
      threeSystemImageName: "lock.circle.fill",
      note: nil
    )
  }
  
  func createInitialHintModel() -> MessengerDialogHintModel {
    return MessengerDialogHintModel(
      lottieAnimationName: nil,
      headerTitle: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Initial.Header.title,
      headerDescription: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Initial.Header.description,
      buttonTitle: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Initial.Button.title,
      oneTitle: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Initial.One.title,
      oneDescription: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Initial.One.description,
      oneSystemImageName: "person.crop.circle.fill",
      twoTitle: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Initial.Two.title,
      twoDescription: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Initial.Two.description,
      twoSystemImageName: "key.fill",
      threeTitle: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Initial.Three.title,
      threeDescription: OChatStrings.MessengerDialogScreenLocalization.Messenger
        .Initial.Three.description,
      threeSystemImageName: "eye.slash.fill",
      note: nil
    )
  }
  
  func createInitialContact(address: String) -> ContactModel {
    return .init(
      name: nil,
      toxAddress: address,
      meshAddress: nil,
      status: .initialChat,
      encryptionPublicKey: nil,
      toxPublicKey: nil,
      pushNotificationToken: nil,
      isNewMessagesAvailable: false,
      isTyping: false,
      canSaveMedia: false,
      isChatHistoryStored: false
    )
  }
  
  func createInitialPlaceholder() -> String {
    OChatStrings.MessengerDialogScreenLocalization.Messenger.Initial.request
  }
  
  func createMainPlaceholder() -> String {
    OChatStrings.MessengerDialogScreenLocalization.Messenger.Initial.message
  }
  
  func createHeaderTitleFrom(_ adress: String) -> String {
    return adress.formatString(minTextLength: 10)
  }
}

// MARK: - Private

private extension MessengerDialogScreenFactory {}

// MARK: - User model

private extension User {
  func copy(isCurrentUser: Bool) -> User {
    return User(id: self.id, name: self.name, avatarURL: self.avatarURL, isCurrentUser: isCurrentUser)
  }
}

// MARK: - Constants

private enum Constants {}

// TODO: - Вынести маппинг

// MARK: - Mapping MessengeRecordingModel

extension MessengeRecordingModel {
  func mapTo() -> Recording {
    Recording(
      duration: duration,
      waveformSamples: waveformSamples,
      url: url
    )
  }
}

// MARK: - Mapping MessengeVideoModel

extension MessengeVideoModel {
  func mapTo() -> Attachment? {
    guard let thumbnail, let full else {
      return nil
    }
    return Attachment(
      id: id,
      thumbnail: thumbnail,
      full: full,
      type: .video
    )
  }
}

// MARK: - Mapping MessengeImageModel

extension MessengeImageModel {
  func mapTo() -> Attachment? {
    guard let thumbnail, let full else {
      return nil
    }
    return Attachment(
      id: id,
      thumbnail: thumbnail,
      full: full,
      type: .image
    )
  }
}
