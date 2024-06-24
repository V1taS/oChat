//
//  MessengerDialogScreenFactory.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Cобытия которые отправляем из Factory в Presenter
protocol MessengerDialogScreenFactoryOutput: AnyObject {}

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
}

/// Фабрика
final class MessengerDialogScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: MessengerDialogScreenFactoryOutput?
}

// MARK: - MessengerDialogScreenFactoryInput

extension MessengerDialogScreenFactory: MessengerDialogScreenFactoryInput {
  func createRequestButtonCancelTitle() -> String {
    MessengerSDKStrings.MessengerDialogScreenLocalization
      .stateRequestButtonCancelTitle
  }
  
  func createRequestHintModel() -> MessengerDialogHintModel {
    return MessengerDialogHintModel(
      lottieAnimationName: nil,
      headerTitle: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateRequestMessengerHeaderTitle,
      headerDescription: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateRequestMessengerHeaderDescription,
      buttonTitle: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateRequestButtonTitle,
      oneTitle: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateRequestMessengerOneTitle,
      oneDescription: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateRequestMessengerOneDescription,
      oneSystemImageName: "envelope.fill",
      twoTitle: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateRequestMessengerTwoTitle,
      twoDescription: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateRequestMessengerTwoDescription,
      twoSystemImageName: "shield.fill",
      threeTitle: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateRequestMessengerThreeTitle,
      threeDescription: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateRequestMessengerThreeDescription,
      threeSystemImageName: "lock.circle.fill", 
      note: nil
    )
  }
    
  func createInitialHintModel() -> MessengerDialogHintModel {
    return MessengerDialogHintModel(
      lottieAnimationName: nil,
      headerTitle: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateInitialMessengerHeaderTitle,
      headerDescription: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateInitialMessengerHeaderDescription,
      buttonTitle: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateInitialButtonTitle,
      oneTitle: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateInitialMessengerOneTitle,
      oneDescription: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateInitialMessengerOneDescription,
      oneSystemImageName: "person.crop.circle.fill",
      twoTitle: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateInitialMessengerTwoTitle,
      twoDescription: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateInitialMessengerTwoDescription,
      twoSystemImageName: "key.fill",
      threeTitle: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateInitialMessengerThreeTitle,
      threeDescription: MessengerSDKStrings.MessengerDialogScreenLocalization
        .stateInitialMessengerThreeDescription,
      threeSystemImageName: "eye.slash.fill",
      note: nil
    )
  }
  
  func createInitialContact(address: String) -> ContactModel {
    return .init(
      name: nil,
      toxAddress: address,
      meshAddress: nil,
      messenges: [
        .init(
          messageType: .systemAttention,
          messageStatus: .sent,
          message: MessengerSDKStrings.MessengerDialogScreenLocalization
            .stateInitialMessengerNote
        )
      ],
      status: .initialChat,
      encryptionPublicKey: nil,
      toxPublicKey: nil, 
      isNewMessagesAvailable: false, 
      isTyping: false
    )
  }
  
  func createPlaceholder() -> String {
    return "Message"
  }
  
  func createInitialPlaceholder() -> String {
    "Введите адрес получателя"
  }
  
  func createMainPlaceholder() -> String {
    "Введите сообщение"
  }
  
  func createHeaderTitleFrom(_ adress: String) -> String {
    return adress.formatString(minTextLength: 20)
  }
}

// MARK: - Private

private extension MessengerDialogScreenFactory {}

// MARK: - Constants

private enum Constants {}
