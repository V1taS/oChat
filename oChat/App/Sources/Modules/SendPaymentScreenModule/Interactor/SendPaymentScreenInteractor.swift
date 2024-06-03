//
//  SendPaymentScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 23.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol SendPaymentScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol SendPaymentScreenInteractorInput {
  /// Получение изображения по URL.
  /// - Parameters:
  ///   - url: URL изображения.
  ///   - completion: Замыкание, вызываемое с загруженным изображением или nil.
  func getImage(for url: URL?, completion: @escaping (UIImage?) -> Void)
}

/// Интерактор
final class SendPaymentScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: SendPaymentScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let uiService: IUIService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы приложения
  init(_ services: IApplicationServices) {
    uiService = services.userInterfaceAndExperienceService.uiService
  }
}

// MARK: - SendPaymentScreenInteractorInput

extension SendPaymentScreenInteractor: SendPaymentScreenInteractorInput {
  func getImage(for url: URL?, completion: @escaping (UIImage?) -> Void) {
    uiService.getImage(for: url, completion: completion)
  }
}

// MARK: - Private

private extension SendPaymentScreenInteractor {}

// MARK: - Constants

private enum Constants {}
