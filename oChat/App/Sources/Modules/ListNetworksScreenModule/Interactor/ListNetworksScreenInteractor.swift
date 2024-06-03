//
//  ListNetworksScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol ListNetworksScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol ListNetworksScreenInteractorInput {}

/// Интерактор
final class ListNetworksScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: ListNetworksScreenInteractorOutput?
}

// MARK: - ListNetworksScreenInteractorInput

extension ListNetworksScreenInteractor: ListNetworksScreenInteractorInput {}

// MARK: - Private

private extension ListNetworksScreenInteractor {}

// MARK: - Constants

private enum Constants {}
