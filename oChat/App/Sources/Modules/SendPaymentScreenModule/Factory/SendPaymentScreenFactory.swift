//
//  SendPaymentScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 23.04.2024.
//

import SwiftUI
import SKAbstractions

/// Cобытия которые отправляем из Factory в Presenter
protocol SendPaymentScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol SendPaymentScreenFactoryInput {
  /// Создать Placeholder
  func createSendCryptoPlaceholderTitle() -> String
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Создать заголовок по отправке токенов
  func createSendCryptoHeaderTitle() -> String
  /// Создать заголовок на какой адрес
  func createWhomCryptoHeaderTitle() -> String
  /// Создать заголовок для основной кнопки
  func createMainButtonTitle() -> String
  /// Создать Placeholder для адреса отправки
  func createWhomCryptoPlaceholderTitle() -> String
  /// Создать заголовок для кнопки применения максимальной суммы
  func createTotalCryptoTitle() -> String
  /// Обновить TokenModel в основной модельку, путем создания новой модели
  func update(model: SendPaymentScreenModel, with tokenModel: TokenModel) -> SendPaymentScreenModel
  /// Обновить TokenModel в основной модельку, путем создания новой модели
  func update(model: SendPaymentScreenModel, with networkModel: TokenNetworkType) -> SendPaymentScreenModel
}

/// Фабрика
final class SendPaymentScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: SendPaymentScreenFactoryOutput?
}

// MARK: - SendPaymentScreenFactoryInput

extension SendPaymentScreenFactory: SendPaymentScreenFactoryInput {
  func update(
    model: SendPaymentScreenModel,
    with networkModel: SKAbstractions.TokenNetworkType
  ) -> SendPaymentScreenModel {
    return SendPaymentScreenModel(
      screenType: model.screenType,
      tokenModel: TokenModel(
        name: model.tokenModel.name,
        ticker: model.tokenModel.ticker,
        address: model.tokenModel.address,
        decimals: model.tokenModel.decimals,
        eip2612: model.tokenModel.eip2612,
        isFeeOnTransfer: model.tokenModel.isFeeOnTransfer,
        network: networkModel,
        availableNetworks: model.tokenModel.availableNetworks,
        tokenAmount: model.tokenModel.tokenAmount,
        currency: model.tokenModel.currency,
        isActive: model.tokenModel.isActive,
        logoURI: model.tokenModel.imageTokenURL?.absoluteString
      )
    )
  }
  
  func update(model: SendPaymentScreenModel, with tokenModel: TokenModel) -> SendPaymentScreenModel {
    return SendPaymentScreenModel(
      screenType: model.screenType,
      tokenModel: tokenModel
    )
  }
  
  func createTotalCryptoTitle() -> String {
    return oChatStrings.SendPaymentScreenLocalization
      .State.TotalCrypto.title
  }
  
  func createWhomCryptoPlaceholderTitle() -> String {
    return oChatStrings.SendPaymentScreenLocalization
      .State.WhomCrypto.Placeholder.title
  }
  
  func createMainButtonTitle() -> String {
    return oChatStrings.SendPaymentScreenLocalization
      .State.MainButton.title
  }
  
  func createSendCryptoHeaderTitle() -> String {
    return oChatStrings.SendPaymentScreenLocalization
      .State.SendCrypto.Header.title
  }
  
  func createWhomCryptoHeaderTitle() -> String {
    return oChatStrings.SendPaymentScreenLocalization
      .State.WhomCrypto.Header.title
  }
  
  func createHeaderTitle() -> String {
    return oChatStrings.SendPaymentScreenLocalization
      .State.Header.title
  }
  
  func createSendCryptoPlaceholderTitle() -> String {
    return oChatStrings.SendPaymentScreenLocalization
      .State.SendCrypto.Placeholder.title
  }
}

// MARK: - Private

private extension SendPaymentScreenFactory {}

// MARK: - Constants

private enum Constants {}
