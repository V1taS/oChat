//
//  PasscodeSettingsScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Cобытия которые отправляем из Factory в Presenter
protocol PasscodeSettingsScreenFactoryOutput: AnyObject {
  /// Открыть экран изменения пароля
  func openChangeAccessCode() async
  
  /// Устанавливаем пароль на вход в приложение
  func openSetAccessCode(_ code: Bool) async
  
  /// Открыть экран изменения фейкового пароля
  func openFakeChangeAccessCode() async
  
  /// Устанавливаем фейковый пароль на вход в приложение
  func openFakeSetAccessCode(_ code: Bool) async
  
  /// Включить индикатор ввода текста
  func setTypingIndicator(_ value: Bool) async
  
  /// Разрешить собеседнику сохранять отправленные вами фото и видео
  func setCanSaveMedia(_ value: Bool) async
  
  /// Разрешить хранение истории переписки
  func setChatHistoryStored(_ value: Bool) async
  
  /// Разрешить изменение голоса
  func setVoiceChanger(_ value: Bool) async
}

/// Cобытия которые отправляем от Presenter к Factory
protocol PasscodeSettingsScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  
  /// Создать виджет модельки для отображения Пароля
  func createPasswordWidgetModels(_ appSettingsModel: AppSettingsModel) -> [WidgetCryptoView.Model]
  
  /// Создать виджет модельки для отображения Безопасности
  func createSecurityWidgetModels(_ appSettingsModel: AppSettingsModel) -> [WidgetCryptoView.Model]
}

/// Фабрика
final class PasscodeSettingsScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: PasscodeSettingsScreenFactoryOutput?
}

// MARK: - PasscodeSettingsScreenFactoryInput

extension PasscodeSettingsScreenFactory: PasscodeSettingsScreenFactoryInput {
  func createPasswordWidgetModels(_ appSettingsModel: AppSettingsModel) -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    let isAppPasswordEnabled = appSettingsModel.appPassword != nil
    let isFakePasswordEnabled = appSettingsModel.fakeAppPassword != nil
    
    let passcodeModel = createWidgetModel(
      title: OChatStrings.PasscodeSettingsScreenLocalization
        .State.Passcode.title,
      initialState: isAppPasswordEnabled,
      description: OChatStrings.PasscodeSettingsScreenLocalization
        .State.Passcode.description,
      action: { [weak self] newValue in
        Task { @MainActor [weak self] in
          await self?.output?.openSetAccessCode(newValue)
        }
      }
    )
    models.append(passcodeModel)
    
    if isAppPasswordEnabled {
      let accessCodeModel = createWidgetWithChevron(
        title: OChatStrings.PasscodeSettingsScreenLocalization
          .State.ChangeAccessCode.title,
        action: { [weak self] in
          Task { @MainActor [weak self] in
            await self?.output?.openChangeAccessCode()
          }
        }
      )
      models.append(accessCodeModel)
    }
    
    let fakeAccessModel = createWidgetModel(
      title: OChatStrings.PasscodeSettingsScreenLocalization
        .State.FakePasscode.title,
      initialState: isFakePasswordEnabled,
      description: OChatStrings.PasscodeSettingsScreenLocalization
        .State.FakePasscode.description,
      action: { [weak self] newValue in
        Task { @MainActor [weak self] in
          await self?.output?.openFakeSetAccessCode(newValue)
        }
      }
    )
    models.append(fakeAccessModel)
    
    if isFakePasswordEnabled {
      let accessCodeModel = createWidgetWithChevron(
        title: OChatStrings.PasscodeSettingsScreenLocalization
          .State.FakeChangeAccessCode.title,
        action: { [weak self] in
          Task { @MainActor [weak self] in
            await self?.output?.openFakeChangeAccessCode()
          }
        }
      )
      models.append(accessCodeModel)
    }
    
    return models
  }
  
  func createSecurityWidgetModels(_ appSettingsModel: AppSettingsModel) -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    
    let typingIndicatorModel = createWidgetModel(
      title: OChatStrings.PasscodeSettingsScreenLocalization
        .State.TypingIndicator.title,
      initialState: appSettingsModel.isTypingIndicatorEnabled,
      description: OChatStrings.PasscodeSettingsScreenLocalization
        .State.TypingIndicator.description,
      action: { [weak self] newValue in
        Task { [weak self] in
          await self?.output?.setTypingIndicator(newValue)
        }
      }
    )
    models.append(typingIndicatorModel)
    
    let canSaveMediaModel = createWidgetModel(
      title: OChatStrings.PasscodeSettingsScreenLocalization
        .State.CanSaveMedia.title,
      initialState: appSettingsModel.canSaveMedia,
      description: OChatStrings.PasscodeSettingsScreenLocalization
        .State.CanSaveMedia.description,
      action: { [weak self] newValue in
        Task { [weak self] in
          await self?.output?.setCanSaveMedia(newValue)
        }
      }
    )
    models.append(canSaveMediaModel)
    
    let chatHistoryStoredModel = createWidgetModel(
      title: OChatStrings.PasscodeSettingsScreenLocalization
        .State.ChatHistory.title,
      initialState: appSettingsModel.isChatHistoryStored,
      description: OChatStrings.PasscodeSettingsScreenLocalization
        .State.ChatHistory.description,
      action: { [weak self] newValue in
        Task { [weak self] in
          await self?.output?.setChatHistoryStored(newValue)
        }
      }
    )
    models.append(chatHistoryStoredModel)
    
    if appSettingsModel.isPremiumEnabled {
      let voiceChangerModel = createWidgetModel(
        title: OChatStrings.PasscodeSettingsScreenLocalization
          .State.VoiceChanger.title,
        initialState: appSettingsModel.isVoiceChangerEnabled,
        description: OChatStrings.PasscodeSettingsScreenLocalization
          .State.VoiceChanger.description,
        isSwitcherEnabled: false,
        action: { [weak self] newValue in
          Task { [weak self] in
            await self?.output?.setVoiceChanger(newValue)
          }
        }
      )
      models.append(voiceChangerModel)
    }
    
    return models
  }
  
  func createHeaderTitle() -> String {
    OChatStrings.PasscodeSettingsScreenLocalization
      .State.Header.title
  }
}

// MARK: - Private

private extension PasscodeSettingsScreenFactory {
  func createWidgetModel(
    title: String,
    initialState: Bool,
    description: String? = nil,
    isSwitcherEnabled: Bool = true,
    action: ((Bool) -> Void)? = nil
  ) -> WidgetCryptoView.Model {
    var descriptionModel: WidgetCryptoView.TextModel?
    
    if let description {
      descriptionModel = .init(
        text: description,
        lineLimit: 2,
        textStyle: .netural
      )
    }
    
    return .init(
      leftSide: .init(
        titleModel: .init(
          text: title,
          lineLimit: 1,
          textStyle: .standart
        ),
        descriptionModel: descriptionModel
      ),
      rightSide: .init(
        itemModel: .switcher(
          initNewValue: initialState,
          isEnabled: isSwitcherEnabled,
          action: action
        )
      ),
      isSelectable: false
    )
  }
  
  func createWidgetWithChevron(
    title: String,
    description: String? = nil,
    action: (() -> Void)?
  ) -> WidgetCryptoView.Model {
    var descriptionModel: WidgetCryptoView.TextModel?
    
    if let description {
      descriptionModel = .init(
        text: description,
        lineLimit: 2,
        textStyle: .netural
      )
    }
    
    return .init(
      leftSide: .init(
        titleModel: .init(text: title, textStyle: .standart),
        descriptionModel: descriptionModel
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
