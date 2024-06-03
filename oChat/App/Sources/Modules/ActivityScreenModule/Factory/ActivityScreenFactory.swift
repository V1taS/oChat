//
//  ActivityScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit

/// Cобытия которые отправляем из Factory в Presenter
protocol ActivityScreenFactoryOutput: AnyObject {
  /// Открыть шторку с подробной информацией по определенной транзакции
  func openActivitySheet()
}

/// Cобытия которые отправляем от Presenter к Factory
protocol ActivityScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Создать список активностей
  func createListActivity() -> [ActivityScreenModel]
}

/// Фабрика
final class ActivityScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: ActivityScreenFactoryOutput?
}

// MARK: - ActivityScreenFactoryInput

extension ActivityScreenFactory: ActivityScreenFactoryInput {
  func createHeaderTitle() -> String {
    return oChatStrings.ActivityScreenLocalization
      .State.Header.title
  }
  
  func createListActivity() -> [ActivityScreenModel] {
    var models: [ActivityScreenModel] = []
    
    let mockOne = ActivityScreenModel(
      date: "Январь 2024",
      listActivity: (1...5).compactMap({ _ in createWidget() })
    )
    let mockTwo = ActivityScreenModel(
      date: "Февраль 2024",
      listActivity: (1...10).compactMap({ _ in createWidget() })
    )
    let mockThree = ActivityScreenModel(
      date: "Март 2024",
      listActivity: (1...20).compactMap({ _ in createWidget() })
    )
    
    models = [
      mockOne,
      mockTwo,
      mockThree
    ]
    return models
  }
}

// MARK: - Private

private extension ActivityScreenFactory {
  func createWidget() -> WidgetCryptoView.Model {
    return .init(
      leftSide: .init(
        imageModel: .custom(image: oChatAsset.currencyEthereum.swiftUIImage),
        titleModel: .init(
          text: "Отправлено",
          textStyle: .standart
        ),
        titleAdditionModel: nil,
        titleAdditionRoundedModel: nil,
        descriptionModel: .init(
          text: "UQC9vCFrizDwENt5fWq7Vb76l55MUgdWk9yJwDYyHP3jY6Fo",
          textStyle: .netural,
          textIsSecure: false
        ),
        descriptionAdditionModel: nil,
        descriptionAdditionRoundedModel: nil
      ),
      rightSide: .init(
        imageModel: nil,
        titleModel: .init(
          text: "- 100 TON",
          textStyle: .standart,
          textIsSecure: false
        ),
        titleAdditionModel: nil,
        titleAdditionRoundedModel: nil,
        descriptionModel: .init(
          text: "31 Dec, 10:30",
          textStyle: .netural
        ),
        descriptionAdditionModel: nil
      ),
      additionCenterTextModel: .init(
        text: "Telegram premium 3 mounths",
        textStyle: .standart
      ),
      additionCenterContent: nil,
      isSelectable: true,
      backgroundColor: nil,
      action: { [weak self] in
        self?.output?.openActivitySheet()
      }
    )
  }
}

// MARK: - Constants

private enum Constants {}
