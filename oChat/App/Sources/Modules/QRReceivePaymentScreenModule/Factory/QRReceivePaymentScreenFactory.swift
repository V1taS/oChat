//
//  QRReceivePaymentScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol QRReceivePaymentScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol QRReceivePaymentScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Создать Описание для экрана
  func createDescriptionTitle(tokenName: String, networkName: String) -> String
  /// Создать заголовок для основной кнопки
  func createMainButtonTitle() -> String
  /// Создать заголовок для кнопки копирования
  func createCopyButtonTitle() -> String
}

/// Фабрика
final class QRReceivePaymentScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: QRReceivePaymentScreenFactoryOutput?
}

// MARK: - QRReceivePaymentScreenFactoryInput

extension QRReceivePaymentScreenFactory: QRReceivePaymentScreenFactoryInput {
  func createDescriptionTitle(tokenName: String, networkName: String) -> String {
    return OChatStrings.QRReceivePaymentScreenLocalization
      .State.Description.title(tokenName, networkName)
  }
  
  func createHeaderTitle() -> String {
    OChatStrings.QRReceivePaymentScreenLocalization
      .State.Header.title
  }
  
  func createMainButtonTitle() -> String {
    OChatStrings.QRReceivePaymentScreenLocalization
      .State.MainButton.title
  }
  
  func createCopyButtonTitle() -> String {
    OChatStrings.QRReceivePaymentScreenLocalization
      .State.CopyButton.title
  }
}

// MARK: - Private

private extension QRReceivePaymentScreenFactory {}

// MARK: - Constants

private enum Constants {}
