//
//  SettingsScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class SettingsScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  /// Количество моих кошельков
  @Published var stateMyWalletsCount: Int = .zero
  /// Выбраная валюта
  @Published var stateCurrencyValue: CurrencyModel.CurrencyType = .usd
  /// Включена опция или нет
  @Published var statePasscodeAndFaceIDValue = false
  /// Включин или выключен Мессенджер
  @Published var stateMessengerIsEnabled = false
  /// Язык в приложении
  @Published var stateCurrentLanguage: AppLanguageType = .english
  
  /// Название приложения
  @Published var stateApplicationTitle = "oChat"
  
  // MARK: - Internal properties
  
  weak var moduleOutput: SettingsScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: SettingsScreenInteractorInput
  private let factory: SettingsScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: SettingsScreenInteractorInput,
       factory: SettingsScreenFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  lazy var viewWillAppear: (() -> Void)? = { [weak self] in
    self?.updateValue()
  }
  
  // MARK: - Internal func
  
  func getAplicationVersion() -> String {
    let appVersion = interactor.getAppVersion()
    let versionTitle = oChatStrings.SettingsScreenLocalization
      .State.Version.title
    return "\(versionTitle) \(appVersion)"
  }
  
  func getHeaderSectionsModels() -> [WidgetCryptoView.Model] {
    factory.createHeaderSectionsModels(
      myWalletsCount: stateMyWalletsCount,
      stateCurrencyValue: stateCurrencyValue
    )
  }
  
  func getSecuritySectionsModels() -> [WidgetCryptoView.Model] {
    let languageValue = factory.createLanguageValue(from: stateCurrentLanguage)
    
    return factory.createSecuritySectionsModels(
      passcodeAndFaceIDValue: statePasscodeAndFaceIDValue,
      messengerIsEnabled: stateMessengerIsEnabled,
      languageValue: languageValue
    )
  }
}

// MARK: - SettingsScreenModuleInput

extension SettingsScreenPresenter: SettingsScreenModuleInput {}

// MARK: - SettingsScreenInteractorOutput

extension SettingsScreenPresenter: SettingsScreenInteractorOutput {}

// MARK: - SettingsScreenFactoryOutput

extension SettingsScreenPresenter: SettingsScreenFactoryOutput {
  func openMyWalletsSection() {
    moduleOutput?.openMyWalletsSection()
  }
  
  func openCurrencySection() {
    moduleOutput?.openCurrencySection()
  }
  
  func openPasscodeAndFaceIDSection() {
    moduleOutput?.openPasscodeAndFaceIDSection()
  }
  
  func openMessengerSection() {
    moduleOutput?.openMessengerSection()
  }
  
  func openNotificationsSection() {
    moduleOutput?.openNotificationsSection()
  }
  
  func openAppearanceSection() {
    moduleOutput?.openAppearanceSection()
  }
  
  func openLanguageSection() {
    moduleOutput?.openLanguageSection()
  }
}

// MARK: - SceneViewModel

extension SettingsScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
  
  var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
    .always
  }
}

// MARK: - Private

private extension SettingsScreenPresenter {
  func updateValue() {
    interactor.getWalletsCount(completion: { [weak self] count in
      self?.stateMyWalletsCount = count
    })
    
    interactor.getCurrentCurrency { [weak self] currencyModel in
      self?.stateCurrencyValue = currencyModel.type
    }
    
    interactor.getIsAccessCodeEnabled { [weak self] isEnabled in
      self?.statePasscodeAndFaceIDValue = isEnabled
    }
    
    stateCurrentLanguage = interactor.getCurrentLanguage()
  }
}

// MARK: - Constants

private enum Constants {}
