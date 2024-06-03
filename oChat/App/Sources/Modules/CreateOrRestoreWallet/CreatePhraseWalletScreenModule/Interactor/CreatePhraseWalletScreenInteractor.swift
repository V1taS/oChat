//
//  CreatePhraseWalletScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol CreatePhraseWalletScreenInteractorOutput: AnyObject {
  /// Что то пошло не так
  func somethingWentWrong()
}

/// События которые отправляем от Presenter к Interactor
protocol CreatePhraseWalletScreenInteractorInput {
  /// Создает новый кошелек с 12-словной сид-фразой.
  /// - Returns: Созданный HD кошелек или nil в случае ошибки.
  func createWallet12Words() -> String?
  
  /// Создает новый кошелек с 24-словной сид-фразой.
  /// - Returns: Созданный HD кошелек или nil в случае ошибки.
  func createWallet24Words() -> String?
  
  /// Показать уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  func showNotification(_ type: NotificationServiceType)
  
  /// Создает кошелек на основе предоставленной мнемонической фразы.
  /// - Parameters:
  ///   - seedPhrase: Мнемоническая фраза, используемая для создания кошелька.
  ///   - walletType: Тип кошелька
  func createWallet(
    seedPhrase: String?,
    walletType: CreatePhraseWalletScreenType,
    completion: ((WalletModel) -> Void)?
  )
}

/// Интерактор
final class CreatePhraseWalletScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: CreatePhraseWalletScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let modelHandlerService: IModelHandlerService
  private let blockchainService: IBlockchainService
  private let notificationService: INotificationService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы приложения
  init(_ services: IApplicationServices) {
    modelHandlerService = services.dataManagementService.modelHandlerService
    blockchainService = services.blockchainService
    notificationService = services.userInterfaceAndExperienceService.notificationService
  }
}

// MARK: - CreatePhraseWalletScreenInteractorInput

extension CreatePhraseWalletScreenInteractor: CreatePhraseWalletScreenInteractorInput {
  func showNotification(_ type: SKAbstractions.NotificationServiceType) {
    notificationService.showNotification(type)
  }
  
  func createWallet12Words() -> String? {
    blockchainService.walletsManager.createWallet12Words()
  }
  
  func createWallet24Words() -> String? {
    blockchainService.walletsManager.createWallet24Words()
  }
  
  func createWallet(
    seedPhrase: String?,
    walletType: CreatePhraseWalletScreenType,
    completion: ((WalletModel) -> Void)?
  ) {
    guard let seedPhrase,
          let walletDetails = blockchainService.walletsManager.getWalletDetails(mnemonic: seedPhrase) else {
      output?.somethingWentWrong()
      return
    }
    
    let wallet = OChatStrings.CreatePhraseWalletScreenLocalization
      .State.Wallet.title
    
    modelHandlerService.getoChatModel { model in
      completion?(
        .init(
          id: .init(),
          name: "\(wallet) - \(model.wallets.count + 1)",
          tokens: [],
          isPrimary: true,
          seedPhrase: seedPhrase,
          publicKey: walletDetails.publicKey,
          privateKey: walletDetails.privateKey,
          createdAt: Date(),
          transactions: [],
          isActive: true,
          walletType: walletType.mapTo()
        )
      )
    }
  }
}

// MARK: - Private

private extension CreatePhraseWalletScreenInteractor {}

// MARK: - Mapping

extension CreatePhraseWalletScreenType {
  func mapTo() -> WalletModel.WalletType {
    switch self {
    case .seedPhrase12:
      return .seedPhrase12
    case .seedPhrase24:
      return .seedPhrase24
    case .highTechImageID:
      return .highTechImageID(nil)
    }
  }
}

// MARK: - Constants

private enum Constants {}
