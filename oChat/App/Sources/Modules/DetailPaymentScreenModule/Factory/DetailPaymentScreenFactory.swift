//
//  DetailPaymentScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 05.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Cобытия которые отправляем из Factory в Presenter
protocol DetailPaymentScreenFactoryOutput: AnyObject {
  /// Открыть экран транзакции
  func openTransactionInformationSheet(_ tokenModel: TokenModel)
}

/// Cобытия которые отправляем от Presenter к Factory
protocol DetailPaymentScreenFactoryInput {
  /// Создать заголовок у кнопки отправить
  func createButtonSendTitle() -> String
  /// Создать заголовок у кнопки получить
  func createButtonReceiveTitle() -> String
  /// Создать список активностей в деталях
  func createListActivity() -> [DetailPaymentScreenModel]
}

/// Фабрика
final class DetailPaymentScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: DetailPaymentScreenFactoryOutput?
}

// MARK: - DetailPaymentScreenFactoryInput

extension DetailPaymentScreenFactory: DetailPaymentScreenFactoryInput {
  func createButtonSendTitle() -> String {
    oChatStrings.DetailPaymentScreenLocalization
      .State.ButtonSend.title
  }
  
  func createButtonReceiveTitle() -> String {
    oChatStrings.DetailPaymentScreenLocalization
      .State.ButtonReceive.title
  }
  
  func createListActivity() -> [DetailPaymentScreenModel] {
    var models: [DetailPaymentScreenModel] = []
    
    let mockOne = DetailPaymentScreenModel(
      date: "Январь 2024",
      listActivity: [.binanceMock, .cardanoMock].compactMap({ model in
        createWidget(model)
      })
    )
    let mockTwo = DetailPaymentScreenModel(
      date: "Февраль 2024",
      listActivity: [TokenModel.cardanoMock, .binanceMock].compactMap({ model in
        createWidget(model)
      })
    )
    let mockThree = DetailPaymentScreenModel(
      date: "Март 2024",
      listActivity: TokenModel.allMocks.compactMap({ model in
        createWidget(model)
      })
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

private extension DetailPaymentScreenFactory {
  func createWidget(_ model: TokenModel) -> WidgetCryptoView.Model {
    return .init(
      leftSide: .init(
        imageModel: .custom(imageURL: model.imageTokenURL),
        titleModel: .init(
          text: "Отправлено",
          textStyle: .standart
        ),
        titleAdditionModel: nil,
        titleAdditionRoundedModel: nil,
        descriptionModel: .init(
          text: "UQC9vCFrizDwENt5fWq7Vb76l55MUgdWk9yJwDYyHP3jY6Fo".formatString(minTextLength: 8),
          textStyle: .netural,
          textIsSecure: false
        ),
        descriptionAdditionModel: nil,
        descriptionAdditionRoundedModel: nil
      ),
      rightSide: .init(
        imageModel: nil,
        titleModel: .init(
          text: "- 100 \(model.ticker)",
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
      additionCenterTextModel: nil,
      additionCenterContent: nil,
      isSelectable: true,
      backgroundColor: nil,
      action: { [weak self] in
        self?.output?.openTransactionInformationSheet(model)
      }
    )
  }
}

// MARK: - Constants

private enum Constants {}
