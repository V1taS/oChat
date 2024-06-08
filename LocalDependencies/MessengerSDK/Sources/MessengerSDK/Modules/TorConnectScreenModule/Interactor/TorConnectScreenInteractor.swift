//
//  TorConnectScreenInteractor.swift
//  MessengerSDK
//
//  Created by Vitalii Sosin on 07.06.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol TorConnectScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol TorConnectScreenInteractorInput {}

/// Интерактор
final class TorConnectScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: TorConnectScreenInteractorOutput?
  
  // MARK: - Private properties
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {}
}

// MARK: - TorConnectScreenInteractorInput

extension TorConnectScreenInteractor: TorConnectScreenInteractorInput {}

// MARK: - Private

private extension TorConnectScreenInteractor {}

// MARK: - Constants

private enum Constants {}
