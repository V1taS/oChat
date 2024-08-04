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
      title: "Заблокировать oChat",
      initialState: isAppPasswordEnabled,
      description: "Требовать пароль для разблокировки",
      action: { [weak self] newValue in
        Task { @MainActor [weak self] in
          await self?.output?.openSetAccessCode(newValue)
        }
      }
    )
    models.append(passcodeModel)
    
    if isAppPasswordEnabled {
      let accessCodeModel = createWidgetWithChevron(
        title: "Изменить пароль доступа",
        action: { [weak self] in
          Task { @MainActor [weak self] in
            await self?.output?.openChangeAccessCode()
          }
        }
      )
      models.append(accessCodeModel)
    }
    
    let fakeAccessModel = createWidgetModel(
      title: "Фейковый доступ в oChat",
      initialState: isFakePasswordEnabled,
      description: "Можно ввести фейковый пароль и откроется пустой чат",
      action: { [weak self] newValue in
        Task { @MainActor [weak self] in
          await self?.output?.openFakeSetAccessCode(newValue)
        }
      }
    )
    models.append(fakeAccessModel)
    
    if isFakePasswordEnabled {
      let accessCodeModel = createWidgetWithChevron(
        title: "Изменить фейковый пароль",
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
      title: "Индикатор ввода текста",
      initialState: appSettingsModel.isTypingIndicatorEnabled,
      description: "Показывает собеседнику, когда Вы набираете сообщение",
      action: { [weak self] newValue in
        Task { [weak self] in
          await self?.output?.setTypingIndicator(newValue)
        }
      }
    )
    models.append(typingIndicatorModel)
    
    let canSaveMediaModel = createWidgetModel(
      title: "Сохранение медиафайлов",
      initialState: appSettingsModel.canSaveMedia,
      description: "Разрешить собеседнику сохранять фото и видео",
      action: { [weak self] newValue in
        Task { [weak self] in
          await self?.output?.setCanSaveMedia(newValue)
        }
      }
    )
    models.append(canSaveMediaModel)
    
    let chatHistoryStoredModel = createWidgetModel(
      title: "Хранение истории переписки",
      initialState: appSettingsModel.isChatHistoryStored,
      description: "Разрешить хранить переписку на устройстве собеседника",
      action: { [weak self] newValue in
        Task { [weak self] in
          await self?.output?.setChatHistoryStored(newValue)
        }
      }
    )
    models.append(chatHistoryStoredModel)
    
    if appSettingsModel.isPremiumEnabled {
      let voiceChangerModel = createWidgetModel(
        title: "Изменение голоса",
        initialState: appSettingsModel.isVoiceChangerEnabled,
        description: "Измените свой голос при аудиозвонках и в аудиозаписях",
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
