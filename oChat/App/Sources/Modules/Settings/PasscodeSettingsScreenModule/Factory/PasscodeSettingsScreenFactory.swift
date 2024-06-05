//
//  PasscodeSettingsScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKUIKit

/// Cобытия которые отправляем из Factory в Presenter
protocol PasscodeSettingsScreenFactoryOutput: AnyObject {
  /// Открыть экран изменения пароля
  func openChangeAccessCode()
  /// Включить или выключить Face ID
  func changeFaceIDState(_ value: Bool)
  /// Включить или выключить экран блокировки
  func changeLockScreenState(_ value: Bool)
}

/// Cобытия которые отправляем от Presenter к Factory
protocol PasscodeSettingsScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Создать виджет модельки для отображения
  func createWidgetModels(stateFaceID: Bool, stateIsShowChangeAccessCode: Bool) -> [SKUIKit.WidgetCryptoView.Model]
}

/// Фабрика
final class PasscodeSettingsScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: PasscodeSettingsScreenFactoryOutput?
}

// MARK: - PasscodeSettingsScreenFactoryInput

extension PasscodeSettingsScreenFactory: PasscodeSettingsScreenFactoryInput {
  func createHeaderTitle() -> String {
    OChatStrings.PasscodeSettingsScreenLocalization
      .State.Header.title
  }
  
  func createWidgetModels(stateFaceID: Bool, stateIsShowChangeAccessCode: Bool) -> [SKUIKit.WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    
    if stateIsShowChangeAccessCode {
      let accessCodeModel = createWidgetWithChevron(
        title: OChatStrings.PasscodeSettingsScreenLocalization
          .State.ChangeAccessCode.title,
        action: { [weak self] in
          self?.output?.openChangeAccessCode()
        }
      )
      models.append(accessCodeModel)
    }
    
    let faceIDModel = createWidgetModel(
      title: OChatStrings.PasscodeSettingsScreenLocalization
        .State.FaceID.title,
      initialState: stateFaceID,
      action: { [weak self] newValue in
        guard let self else {
          return
        }
        output?.changeFaceIDState(newValue)
      }
    )
    models.append(faceIDModel)
    
    let passcodeModel = createWidgetModel(
      title: OChatStrings.PasscodeSettingsScreenLocalization
        .State.LockScreen.title,
      initialState: stateIsShowChangeAccessCode,
      action: { [weak self] newValue in
        guard let self else {
          return
        }
        output?.changeLockScreenState(newValue)
      }
    )
    models.append(passcodeModel)
    return models
  }
}

// MARK: - Private

private extension PasscodeSettingsScreenFactory {
  func createWidgetModel(
    title: String,
    initialState: Bool,
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
        itemModel: .switcher(
          initNewValue: initialState,
          action: action
        )
      ),
      isSelectable: false
    )
  }
  
  func createWidgetWithChevron(
    title: String,
    action: (() -> Void)?
  ) -> WidgetCryptoView.Model {
    return .init(
      leftSide: .init(
        titleModel: .init(text: title, textStyle: .standart),
        descriptionModel: nil
      ),
      rightSide: .init(
        imageModel: .chevron
      ),
      action: action
    )
  }
}

// MARK: - Constants

private enum Constants {}
