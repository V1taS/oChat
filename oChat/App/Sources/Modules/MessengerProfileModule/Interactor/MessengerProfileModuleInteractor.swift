//
//  MessengerProfileModuleInteractor.swift
//  MessengerSDK
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle

/// События которые отправляем из Interactor в Presenter
protocol MessengerProfileModuleInteractorOutput: AnyObject {
  /// Был получен адресс пополнения
  func didReceiveMyOnionAddress(_ address: String)
  /// Был получен сгенирированный QR
  func didReceiveQrImage(_ image: UIImage?)
}

/// События которые отправляем от Presenter к Interactor
protocol MessengerProfileModuleInteractorInput {
  /// Показать уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  func showNotification(_ type: NotificationServiceType)
  /// Копирует текст в буфер обмена.
  /// - Parameters:
  ///   - text: Текст для копирования.
  func copyToClipboard(text: String)
  
  /// Получить мой адресс onion
  func getOnionAdress()
  
  /// Получить сгенирированный QR
  func getQrImageWith(onionAdress: String)
}

/// Интерактор
final class MessengerProfileModuleInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MessengerProfileModuleInteractorOutput?
  
  // MARK: - Private properties
  
  private let notificationService: INotificationService
  private let uiService: IUIService
  private let systemService: ISystemService
  private var p2pChatManager: IP2PChatManager
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    notificationService = services.userInterfaceAndExperienceService.notificationService
    uiService = services.userInterfaceAndExperienceService.uiService
    systemService = services.userInterfaceAndExperienceService.systemService
    p2pChatManager = services.messengerService.p2pChatManager
  }
}

// MARK: - MessengerProfileModuleInteractorInput

extension MessengerProfileModuleInteractor: MessengerProfileModuleInteractorInput {
  func getOnionAdress() {
    Task { [weak self] in
      guard let self else { return }
      let toxAddress = await p2pChatManager.getToxAddress()
      output?.didReceiveMyOnionAddress(toxAddress ?? "")
    }
  }
  
  func getQrImageWith(onionAdress: String) {
    let logoImage = UIImage(named: SKStyleAsset.oChatLogo.name, in: SKStyle.bundle, with: nil)!
    let cacheImageURL = cacheImage(logoImage, withName: "oChatLogo")
    
    // Получаем изображение из кэша
    uiService.getImage(for: cacheImageURL) { [weak self] image in
      guard let self else { return }
      
      // Генерируем QR код с изображением внутри
      uiService.generateQRCode(
        from: "\(Constants.basePart)\(onionAdress)",
        backgroundColor: .clear,
        foregroundColor: SKStyleAsset.constantNavy.swiftUIColor,
        iconIntoQR: image,
        iconSize: CGSize(width: 100, height: 158),
        iconBackgroundColor: .clear) { [weak self] qrImage in
          self?.output?.didReceiveQrImage(qrImage)
        }
    }
  }
  
  func copyToClipboard(text: String) {
    systemService.copyToClipboard(text: text)
  }
  
  func showNotification(_ type: SKAbstractions.NotificationServiceType) {
    notificationService.showNotification(type)
  }
}

// MARK: - Private

private extension MessengerProfileModuleInteractor {
  func cacheImage(_ image: UIImage, withName name: String, asJPEG: Bool = false) -> URL? {
    // Получаем директорию для кэширования данных
    let fileManager = FileManager.default
    let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
    
    // Создаем URL для файла в кэше
    guard let fileURL = cacheDirectory?.appendingPathComponent(name + (asJPEG ? ".jpeg" : ".png")) else {
      return nil
    }
    
    do {
      // Переводим UIImage в Data
      let imageData = asJPEG ? image.jpegData(compressionQuality: 1.0) : image.pngData()
      guard let data = imageData else {
        return nil
      }
      
      // Сохраняем данные в файл
      try data.write(to: fileURL)
      return fileURL
    } catch {
      return nil
    }
  }
}

// MARK: - Constants

private enum Constants {
  static let basePart = "onionChat://new_contact/"
}
