//
//  ConfirmSendPaymentScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol ConfirmSendPaymentScreenInteractorOutput: AnyObject {
  /// Был получен список Токенов
  func didReceiveMyWalletAddress(_ walletAddress: String)
  /// Была получена комиссия для перевода
  func didReceiveTransactionFee(_ transactionFee: Decimal)
  /// Платеж успешно отправлен
  func paymentSentSuccessfully()
  /// Платеж не отправлен
  func paymentNotSent()
}

/// События которые отправляем от Presenter к Interactor
protocol ConfirmSendPaymentScreenInteractorInput {
  /// Получить адрес моего кошелька
  func getMyWalletAddress()
  /// Получить комиссию транзакции
  func getTransactionFee()
  /// Пройти валидацию отправки платежа
  func passTokenSendingValidation()
}

/// Интерактор
final class ConfirmSendPaymentScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: ConfirmSendPaymentScreenInteractorOutput?
  
  // MARK: - Private properties
  
  let notificationService: INotificationService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(services: IApplicationServices) {
    notificationService = services.userInterfaceAndExperienceService.notificationService
  }
}

// MARK: - ConfirmSendPaymentScreenInteractorInput

extension ConfirmSendPaymentScreenInteractor: ConfirmSendPaymentScreenInteractorInput {
  func passTokenSendingValidation() {
#warning("TODO: - Валидация, что платеж можно провести")
    output?.paymentSentSuccessfully()
  }
  
  func getTransactionFee() {
    output?.didReceiveTransactionFee(0.1289)
  }
  
  func getMyWalletAddress() {
    let myWalletAddress = "UQApvTCMgnmqvXiJwAmF_LVtNJeEIUzZUOGR_h66t8FilkNf"
    output?.didReceiveMyWalletAddress(myWalletAddress)
  }
}

// MARK: - Private

private extension ConfirmSendPaymentScreenInteractor {}

// MARK: - Constants

private enum Constants {}
