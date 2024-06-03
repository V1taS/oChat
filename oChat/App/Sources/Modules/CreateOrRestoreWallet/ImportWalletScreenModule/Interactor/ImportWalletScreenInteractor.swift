//
//  ImportWalletScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol ImportWalletScreenInteractorOutput: AnyObject {
  /// Кошелек успешно импортирован
  func walletImportedSuccessfully()
  /// Что то пошло не так
  func somethingWentWrong()
}

/// События которые отправляем от Presenter к Interactor
protocol ImportWalletScreenInteractorInput {
  /// Валидация основной кнопки
  func validationSeedPhrase(
    _ phraseText: String
  ) -> (isValidation: Bool, helperText: String?)
  /// Проверить возможность импорта кошелька
  func checkingTheImportedWallet(
    _ walletType: ImportWalletScreenType,
    _ phraseText: String
  )
  /// Показать уведомление
  func showNotification(_ type: NotificationServiceType)
}

/// Интерактор
final class ImportWalletScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: ImportWalletScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let notificationService: INotificationService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(services: IApplicationServices) {
    notificationService = services.userInterfaceAndExperienceService.notificationService
  }
}

// MARK: - ImportWalletScreenInteractorInput

extension ImportWalletScreenInteractor: ImportWalletScreenInteractorInput {
  func checkingTheImportedWallet(
    _ walletType: ImportWalletScreenType,
    _ phraseText: String
  ) {
#warning("TODO: - Когда подключу библиотеку и сделаю сервис по работе с криптой, вызываем здесь функцию для импорта кошелька")
    output?.walletImportedSuccessfully()
  }
  
  func validationSeedPhrase(_ phraseText: String) -> (isValidation: Bool, helperText: String?) {
    return phraseValidation(phrase: phraseText)
  }
  
  func showNotification(_ type: NotificationServiceType) {
    notificationService.showNotification(type)
  }
}

// MARK: - Private

private extension ImportWalletScreenInteractor {
  func phraseValidation(phrase: String) -> (isValidation: Bool, helperText: String?) {
#warning("TODO: - Скорее всего в библиотеке по крипте будет метод по проверке валидности СИД фразы, доработать после создания сервиса по работе с криптой")
    // Все проверки пройдены
    return (true, nil)
  }
}

// MARK: - Constants

private enum Constants {}
