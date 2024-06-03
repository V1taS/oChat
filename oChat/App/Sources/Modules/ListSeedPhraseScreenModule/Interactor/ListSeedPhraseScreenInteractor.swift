//
//  ListSeedPhraseScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol ListSeedPhraseScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol ListSeedPhraseScreenInteractorInput {
  /// Показать  уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  func showNotification(_ type: NotificationServiceType)
  /// Копирует текст в буфер обмена.
  /// - Parameters:
  ///   - text: Текст для копирования.
  ///   - completion: Замыкание, вызываемое с результатом операции.
  func copyToClipboard(text: String, completion: @escaping (Result<Void, SystemServiceError>) -> Void)
  
  /// Сохраняет модель кошелька в хранилище.
  /// - Parameters:
  ///   - walletModel: Модель кошелька, которую необходимо сохранить.
  ///   - completion: Опциональный коллбэк, который выполняется после завершения операции сохранения.
  func saveWallet(_ walletModel: WalletModel, completion: (() -> Void)?)
}

/// Интерактор
final class ListSeedPhraseScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: ListSeedPhraseScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let notificationService: INotificationService
  private let systemService: ISystemService
  private let modelHandlerService: IModelHandlerService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    self.notificationService = services.userInterfaceAndExperienceService.notificationService
    self.systemService = services.userInterfaceAndExperienceService.systemService
    modelHandlerService = services.dataManagementService.modelHandlerService
  }
}

// MARK: - ListSeedPhraseScreenInteractorInput

extension ListSeedPhraseScreenInteractor: ListSeedPhraseScreenInteractorInput {
  func copyToClipboard(text: String, completion: @escaping (Result<Void, SKAbstractions.SystemServiceError>) -> Void) {
    systemService.copyToClipboard(text: text, completion: completion)
  }
  
  func showNotification(_ type: SKAbstractions.NotificationServiceType) {
    notificationService.showNotification(type)
  }
  
  func saveWallet(_ walletModel: WalletModel, completion: (() -> Void)?) {
    modelHandlerService.saveWalletModel(walletModel, completion: completion)
  }
}

// MARK: - Private

private extension ListSeedPhraseScreenInteractor {}

// MARK: - Constants

private enum Constants {}
