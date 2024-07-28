//
//  SettingsScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit
import SKStyle
import SKAbstractions

/// Cобытия которые отправляем из Factory в Presenter
protocol SettingsScreenFactoryOutput: AnyObject {
  /// Открыть экран настроек по безопасности
  func openPasscodeAndFaceIDSection()
  /// Открыть экран настроек уведомлений
  func openNotificationsSection()
  /// Открыть экран настроек внешнего вида
  func openAppearanceSection()
  /// Открыть экран настроек языка
  func openLanguageSection()
  /// Открыть секцию с профилем
  func openMyProfileSection()
}

/// Cобытия которые отправляем от Presenter к Factory
protocol SettingsScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  
  /// Создать верхнюю секцию
  func createTopWidgetModels(
    _ appSettingsModel: AppSettingsModel,
    languageValue: String
  ) -> [WidgetCryptoView.Model]
  
  /// Создать верхнюю секцию
  func createBottomWidgetModels(
    _ appSettingsModel: AppSettingsModel
  ) -> [WidgetCryptoView.Model]
  
  /// Создаем заголовок, какой язык выбран в приложении Русский или Английский
  func createLanguageValue(from languageType: AppLanguageType) -> String
}

/// Фабрика
final class SettingsScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: SettingsScreenFactoryOutput?
}

// MARK: - SettingsScreenFactoryInput

extension SettingsScreenFactory: SettingsScreenFactoryInput {
  func createLanguageValue(from languageType: SKAbstractions.AppLanguageType) -> String {
    switch languageType {
    case .english:
      return OChatStrings.SettingsScreenLocalization
        .State.LanguageType.English.title
    case .russian:
      return  OChatStrings.SettingsScreenLocalization
        .State.LanguageType.Russian.title
    }
  }
  
  func createHeaderTitle() -> String {
    return OChatStrings.SettingsScreenLocalization
      .State.Header.title
  }
  
  func createTopWidgetModels(
    _ appSettingsModel: AppSettingsModel,
    languageValue: String
  ) -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    
    let profileModel = createWidgetWithChevron(
      image: Image(systemName: "person.fill"),
      backgroundColor: #colorLiteral(red: 0.1844805479, green: 0.5407295227, blue: 0.9590529799, alpha: 1),
      title: OChatStrings.SettingsScreenLocalization.State.profile,
      additionRightTitle: "",
      action: { [weak self] in
        self?.output?.openMyProfileSection()
      }
    )
    models.append(profileModel)
    
    if !appSettingsModel.isFakeAccessEnabled {
      let securityModel = createWidgetWithChevron(
        image: Image(systemName: "lock"),
        backgroundColor: #colorLiteral(red: 0.4229286313, green: 0.5245543122, blue: 0.6798206568, alpha: 1),
        title: OChatStrings.SettingsScreenLocalization
          .State.PasscodeAndFaceID.title,
        action: { [weak self] in
          self?.output?.openPasscodeAndFaceIDSection()
        }
      )
      models.append(securityModel)
      
      let notificationsModel = createWidgetWithChevron(
        image: Image(systemName: "bell"),
        backgroundColor: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1),
        title: OChatStrings.SettingsScreenLocalization
          .State.Notifications.title,
        action: { [weak self] in
          self?.output?.openNotificationsSection()
        }
      )
      models.append(notificationsModel)
      
      let languageModel = createWidgetWithChevron(
        image: Image(systemName: "globe"),
        backgroundColor: #colorLiteral(red: 0.4229286313, green: 0.5245543122, blue: 0.6798206568, alpha: 1),
        title: OChatStrings.SettingsScreenLocalization
          .State.Language.title,
        additionRightTitle: languageValue,
        action: { [weak self] in
          self?.output?.openLanguageSection()
        }
      )
      models.append(languageModel)
    }

    let appearanceModel = createWidgetWithChevron(
      image: Image(systemName: "applepencil.and.scribble"),
      backgroundColor: #colorLiteral(red: 0.9988374114, green: 0.6133651733, blue: 0.03555859998, alpha: 1),
      title: OChatStrings.SettingsScreenLocalization
        .State.Appearance.title,
      action: { [weak self] in
        self?.output?.openAppearanceSection()
      }
    )
    models.append(appearanceModel)
    return models
  }
  
  func createBottomWidgetModels(
    _ appSettingsModel: AppSettingsModel
  ) -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    
    let profileModel = createWidgetWithChevron(
      image: Image(systemName: "trash"),
      backgroundColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),
      title: "Удалить и выйти",
      additionRightTitle: "",
      action: { [weak self] in
        // TODO: - сделать логику удаления чата
      }
    )
    models.append(profileModel)
    
    return models
  }
}

// MARK: - Private

private extension SettingsScreenFactory {
  func createWidgetWithChevron(
    image: Image,
    backgroundColor: UIColor,
    title: String,
    additionRightTitle: String? = nil,
    action: (() -> Void)?
  ) -> WidgetCryptoView.Model {
    var textModel: WidgetCryptoView.TextModel?
    if let additionRightTitle {
      textModel = .init(text: additionRightTitle, textStyle: .netural)
    }
    
    return .init(
      leftSide: .init(
        itemModel: .custom(
          item: AnyView(
            Color(backgroundColor)
              .clipShape(RoundedRectangle(cornerRadius: .s2 / 1.3))
              .overlay {
                image
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .fontWeight(.bold)
                  .frame(height: .s5)
                  .foregroundColor(SKStyleAsset.constantGhost.swiftUIColor)
                  .allowsHitTesting(false)
              }
          ),
          size: .custom(width: .s8, height: .s8),
          isHitTesting: false
        ),
        titleModel: nil,
        descriptionModel: .init(text: title, textStyle: .standart)
      ),
      rightSide: .init(
        imageModel: .chevron,
        titleModel: nil,
        descriptionModel: textModel
      ),
      action: action
    )
  }
}

// MARK: - Constants

private enum Constants {}
