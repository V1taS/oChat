//
//  HighTechImageIDScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol HighTechImageIDScreenInteractorOutput: AnyObject {
  /// Обработчик неопределенной ошибки
  func didReceiveNotDefined()
  
  /// Обработчик ошибки "данные слишком велики"
  func didReceiveDataTooBig()
  
  /// Обработчик ошибки "изображение слишком мало"
  func didReceiveImageTooSmall()
  
  /// Обработчик ошибки "нет данных в изображении"
  func didReceiveNoDataInImage()
  
  /// Что то пошло не так
  func somethingWentWrong()
}

/// События которые отправляем от Presenter к Interactor
protocol HighTechImageIDScreenInteractorInput {
  /// Показать позитивное уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  func showNotification(_ type: NotificationServiceType)
  
  /// Внедряет сид-фразу в данные изображения, используя стеганографию и дополнительный пароль для шифрования.
  /// - Parameters:
  ///   - seedPhrase: Сид-фраза для внедрения в изображение.
  ///   - passcode: Пароль, используемый для шифрования сид-фразы перед внедрением.
  ///   - image: Исходные данные изображения, в которые будет внедрена зашифрованная сид-фраза.
  ///   - completion: Блок завершения, который вызывается после попытки внедрения.
  ///     Возвращает `Data?`, содержащий измененные данные изображения, или `nil` в случае неудачи.
  func embedSeedPhraseIntoImage(
    seedPhrase: String,
    passcode: String,
    in image: Data,
    completion: ((_ modifiedImageID: Data?) -> Void)?
  )
  
  /// Извлекает сид-фразу из данных изображения, используя стеганографические методы и пароль для дешифрования.
  /// - Parameters:
  ///   - passcode: Пароль, используемый для дешифрования сид-фразы, скрытой в изображении.
  ///   - image: Данные изображения, из которых необходимо извлечь сид-фразу.
  ///   - completion: Блок завершения, который вызывается после попытки извлечения.
  ///     Возвращает извлеченную сид-фразу в виде строки или `nil`, если извлечение не удалось.
  func extractSeedPhraseFromImage(
    passcode: String,
    in image: Data,
    completion: ((_ seedPhrase: String?) -> Void)?
  )
  
  /// Создает кошелек на основе предоставленной мнемонической фразы.
  /// - Parameters:
  ///   - seedPhrase: Опциональная мнемоническая фраза, используемая для создания кошелька.
  ///   - imageID: Изображение с сид фразой
  ///   - completion: Блок завершения, который вызывается после создания кошелька.
  func createWallet(
    seedPhrase: String?,
    imageID: Data?,
    completion: ((WalletModel) -> Void)?
  )
  
  /// Сохраняет модель кошелька в постоянное хранилище.
  /// - Parameters:
  ///   - walletModel: Модель кошелька, которую необходимо сохранить.
  ///   - completion: Опциональный коллбэк, который выполняется после завершения операции сохранения.
  func saveWallet(
    walletModel: WalletModel,
    completion: (() -> Void)?
  )
  
  /// Проверяет валидность мнемонической фразы.
  /// - Parameter input: Входная мнемоническая фраза.
  /// - Returns: Возвращает `true`, если фраза валидна, иначе `false`.
  func isValidMnemonic(_ input: String) -> Bool
}

/// Интерактор
final class HighTechImageIDScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: HighTechImageIDScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let notificationService: INotificationService
  private let cryptoService: ICryptoService
  private let steganographyService: ISteganographyService
  private let blockchainService: IBlockchainService
  private let modelHandlerService: IModelHandlerService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    notificationService = services.userInterfaceAndExperienceService.notificationService
    cryptoService = services.accessAndSecurityManagementService.cryptoService
    steganographyService = services.accessAndSecurityManagementService.steganographyService
    blockchainService = services.blockchainService
    modelHandlerService = services.dataManagementService.modelHandlerService
  }
}

// MARK: - HighTechImageIDScreenInteractorInput

extension HighTechImageIDScreenInteractor: HighTechImageIDScreenInteractorInput {
  func showNotification(_ type: NotificationServiceType) {
    notificationService.showNotification(type)
  }
  
  func isValidMnemonic(_ input: String) -> Bool {
    blockchainService.walletsManager.isValidMnemonic(input)
  }
  
  func saveWallet(walletModel: WalletModel, completion: (() -> Void)?) {
    modelHandlerService.saveWalletModel(walletModel, completion: completion)
  }
  
  func createWallet(
    seedPhrase: String?,
    imageID: Data?,
    completion: ((WalletModel) -> Void)?
  ) {
    guard let seedPhrase,
          let walletDetails = blockchainService.walletsManager.getWalletDetails(mnemonic: seedPhrase) else {
      output?.somethingWentWrong()
      return
    }
    
    let wallet = oChatStrings.HighTechImageIDScreenLocalization
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
          walletType: .highTechImageID(imageID)
        )
      )
    }
  }
  
  func extractSeedPhraseFromImage(
    passcode: String,
    in image: Data,
    completion: ((_ seedPhrase: String?) -> Void)?
  ) {
    steganographyService.getTextBase64From(image: image) { [weak self] result in
      guard let self else {
        return
      }
      
      switch result {
      case let .success(seedPhraseEncryptBase64):
        let seedPhrase = cryptoService.decrypt(seedPhraseEncryptBase64, privateKey: passcode)
        if let seedPhrase, blockchainService.walletsManager.isValidMnemonic(seedPhrase) {
          completion?(seedPhrase)
        } else {
          output?.didReceiveNoDataInImage()
        }
      case let .failure(error):
        switch error {
        case .notDefined:
          output?.didReceiveNotDefined()
        case .dataTooBig:
          output?.didReceiveDataTooBig()
        case .imageTooSmall:
          output?.didReceiveImageTooSmall()
        case .noDataInImage:
          output?.didReceiveNoDataInImage()
        }
      }
    }
  }
  
  func embedSeedPhraseIntoImage(
    seedPhrase: String,
    passcode: String,
    in image: Data,
    completion: ((_ modifiedImageID: Data?) -> Void)?
  ) {
    guard let publicEncryptKey = cryptoService.publicKey(from: passcode),
          let seedPhraseEncrypted = cryptoService.encrypt(seedPhrase, publicKey: publicEncryptKey) else {
      completion?(nil)
      output?.somethingWentWrong()
      return
    }
    
    steganographyService.hideTextBase64(seedPhraseEncrypted, withImage: image) { [weak self] result in
      guard let self else {
        return
      }
      
      switch result {
      case let .success(imageData):
        completion?(imageData)
      case let .failure(error):
        switch error {
        case .notDefined:
          output?.didReceiveNotDefined()
        case .dataTooBig:
          output?.didReceiveDataTooBig()
        case .imageTooSmall:
          output?.didReceiveImageTooSmall()
        case .noDataInImage:
          output?.didReceiveNoDataInImage()
        }
      }
    }
  }
}

// MARK: - Private

private extension HighTechImageIDScreenInteractor {}

// MARK: - Constants

private enum Constants {}
