//
//  MyWalletsScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol MyWalletsScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol MyWalletsScreenInteractorInput {
  /// Возвращает содержимое, включающее модели кошельков и текущую валюту.
  /// - Parameter completion: Замыкание, которое принимает два значения:
  ///   - `walletModels`: Массив моделей кошельков.
  ///   - `currency`: Строка, представляющая текущую валюту.
  func getContent(completion: @escaping (_ walletModels: [WalletModel], _ currency: String) -> Void)
}

/// Интерактор
final class MyWalletsScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MyWalletsScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let modelHandlerService: any IModelHandlerService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    modelHandlerService = services.dataManagementService.modelHandlerService
  }
}

// MARK: - MyWalletsScreenInteractorInput

extension MyWalletsScreenInteractor: MyWalletsScreenInteractorInput {
  func getContent(completion: @escaping (_ walletModels: [WalletModel], _ currency: String) -> Void) {
    modelHandlerService.getoChatModel { oChatModel in
      completion(oChatModel.wallets, oChatModel.appSettingsModel.currentCurrency.type.details.id)
    }
  }
}

// MARK: - Private

private extension MyWalletsScreenInteractor {}

// MARK: - Constants

private enum Constants {}
