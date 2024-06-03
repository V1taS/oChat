//
//  AppearanceAppScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol AppearanceAppScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol AppearanceAppScreenInteractorInput {
  /// Сохраняет выбранную тему в UserDefaults.
  /// - Parameter interfaceStyle: Цветовая схема, которая будет сохранена. Если значение `nil`, предпочтение темы удаляется.
  func saveColorScheme(_ interfaceStyle: UIUserInterfaceStyle?)
  
  /// Получает текущую тему приложения на основе сохраненных настроек.
  /// - Returns: Возвращает `UIUserInterfaceStyle?`, представляющую текущую тему приложения. Возвращает `nil`, если тема не была установлена.
  func getColorScheme() -> UIUserInterfaceStyle?
}

/// Интерактор
final class AppearanceAppScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: AppearanceAppScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let uiService: IUIService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    uiService = services.userInterfaceAndExperienceService.uiService
  }
}

// MARK: - AppearanceAppScreenInteractorInput

extension AppearanceAppScreenInteractor: AppearanceAppScreenInteractorInput {
  func saveColorScheme(_ interfaceStyle: UIUserInterfaceStyle?) {
    uiService.saveColorScheme(interfaceStyle)
  }
  
  func getColorScheme() -> UIUserInterfaceStyle? {
    uiService.getColorScheme()
  }
}

// MARK: - Private

private extension AppearanceAppScreenInteractor {}

// MARK: - Constants

private enum Constants {}
