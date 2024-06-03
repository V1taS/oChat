//
//  QRReceivePaymentScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//

import SwiftUI
import SKAbstractions
import SKUIKit

/// События которые отправляем из Interactor в Presenter
protocol QRReceivePaymentScreenInteractorOutput: AnyObject {
  /// Был получен адресс пополнения
  func didReceiveReplenishmentAddress(_ address: String)
  /// Был получен сгенирированный QR
  func didReceiveQrImage(_ image: UIImage?)
}

/// События которые отправляем от Presenter к Interactor
protocol QRReceivePaymentScreenInteractorInput {
  /// Получить адресс пополнения
  func getReplenishmentAddress()
  /// Получить сгенирированный QR
  func getQrImageWith(tokenModel: TokenModel)
  /// Показать уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  func showNotification(_ type: NotificationServiceType)
  /// Копирует текст в буфер обмена.
  /// - Parameters:
  ///   - text: Текст для копирования.
  func copyToClipboard(text: String)
}

/// Интерактор
final class QRReceivePaymentScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: QRReceivePaymentScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let notificationService: INotificationService
  private let uiService: IUIService
  private let systemService: ISystemService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    notificationService = services.userInterfaceAndExperienceService.notificationService
    uiService = services.userInterfaceAndExperienceService.uiService
    systemService = services.userInterfaceAndExperienceService.systemService
  }
}

// MARK: - QRReceivePaymentScreenInteractorInput

extension QRReceivePaymentScreenInteractor: QRReceivePaymentScreenInteractorInput {
  func copyToClipboard(text: String) {
    systemService.copyToClipboard(text: text)
  }
  
  func showNotification(_ type: SKAbstractions.NotificationServiceType) {
    notificationService.showNotification(type)
  }
  
  func getReplenishmentAddress() {
    output?.didReceiveReplenishmentAddress(Constants.replenishmentAddress)
  }
  
  func getQrImageWith(tokenModel: TokenModel) {
    uiService.getImage(for: tokenModel.imageTokenURL) { [weak self] image in
      guard let self else {
        return
      }
      
      uiService.generateQRCode(
        from: Constants.replenishmentAddress,
        iconIntoQR: image) { [weak self] qrImage in
          self?.output?.didReceiveQrImage(qrImage)
        }
    }
  }
}

// MARK: - Private

private extension QRReceivePaymentScreenInteractor {}

// MARK: - Constants

private enum Constants {
  static let replenishmentAddress = "UQApvTCMgnmqvXiJwAmF_LVtNJeEIUzZUOGR_h66t8FilkNf"
}
