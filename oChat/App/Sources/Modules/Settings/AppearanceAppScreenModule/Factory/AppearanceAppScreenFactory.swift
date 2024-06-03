//
//  AppearanceAppScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKUIKit

/// Cобытия которые отправляем из Factory в Presenter
protocol AppearanceAppScreenFactoryOutput: AnyObject {
  /// Сохраняет выбранную тему в UserDefaults.
  /// - Parameter interfaceStyle: Цветовая схема, которая будет сохранена. Если значение `nil`, предпочтение темы удаляется.
  func saveColorScheme(_ interfaceStyle: UIUserInterfaceStyle?)
}

/// Cобытия которые отправляем от Presenter к Factory
protocol AppearanceAppScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Создать виджет модельки для отображения
  func createWidgetModels(_ colorScheme: UIUserInterfaceStyle?) -> [SKUIKit.WidgetCryptoView.Model]
}

/// Фабрика
final class AppearanceAppScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: AppearanceAppScreenFactoryOutput?
}

// MARK: - AppearanceAppScreenFactoryInput

extension AppearanceAppScreenFactory: AppearanceAppScreenFactoryInput {
  func createWidgetModels(_ colorScheme: UIUserInterfaceStyle?) -> [SKUIKit.WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    
    let automaticThemeModel = createWidgetModel(
      title: oChatStrings.AppearanceAppScreenLocalization
        .State.Theme.automatic,
      initNewValue: colorScheme == nil,
      isChangeValue: colorScheme != nil,
      colorScheme: .unspecified,
      action: { [weak self] _ in
        guard let self, colorScheme != nil else {
          return
        }
        output?.saveColorScheme(nil)
      }
    )
    
    let lightThemeModel = createWidgetModel(
      title: oChatStrings.AppearanceAppScreenLocalization
        .State.Theme.light,
      initNewValue: colorScheme == .light,
      isChangeValue: colorScheme != .light,
      colorScheme: .light,
      action: { [weak self] _ in
        guard let self, colorScheme != .light else {
          return
        }
        output?.saveColorScheme(.light)
      }
    )
    
    let darkThemeModel = createWidgetModel(
      title: oChatStrings.AppearanceAppScreenLocalization
        .State.Theme.dark,
      initNewValue: colorScheme == .dark,
      isChangeValue: colorScheme != .dark,
      colorScheme: .dark,
      action: { [weak self] _ in
        guard let self, colorScheme != .dark else {
          return
        }
        output?.saveColorScheme(.dark)
      }
    )
    
    models = [
      automaticThemeModel,
      lightThemeModel,
      darkThemeModel
    ]
    return models
  }
  
  func createHeaderTitle() -> String {
    oChatStrings.AppearanceAppScreenLocalization
      .State.Header.title
  }
}

// MARK: - Private

private extension AppearanceAppScreenFactory {
  func createWidgetModel(
    title: String,
    initNewValue: Bool,
    isChangeValue: Bool,
    colorScheme: UIUserInterfaceStyle?,
    action: ((Bool) -> Void)?
  ) -> WidgetCryptoView.Model {
    return .init(
      leftSide: .init(
        titleModel: .init(
          text: title,
          lineLimit: 1,
          textStyle: .standart
        )
      ),
      rightSide: .init(
        itemModel: .radioButtons(
          initNewValue: initNewValue,
          isChangeValue: isChangeValue,
          action: action
        )
      ),
      isSelectable: true) { [weak self] in
        guard let self else {
          return
        }
        switch colorScheme ?? .unspecified {
        case .light:
          output?.saveColorScheme(.light)
        case .dark:
          output?.saveColorScheme(.dark)
        default:
          output?.saveColorScheme(nil)
        }
      }
  }
}

// MARK: - Constants

private enum Constants {}
