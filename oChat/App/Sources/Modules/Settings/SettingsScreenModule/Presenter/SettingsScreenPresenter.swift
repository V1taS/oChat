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
  
  /// Включена опция или нет
  @Published var statePasscodeAndFaceIDValue = false
  /// Включин или выключен Мессенджер
  @Published var stateMessengerIsEnabled = false
  /// Язык в приложении
  @Published var stateCurrentLanguage: AppLanguageType = .english
  
  /// Название приложения
  @Published var stateApplicationTitle = "oChat"
  
  @Published var stateSectionsModels: [WidgetCryptoView.Model] = []
  
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
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    initialSetup()
  }
  
  lazy var viewWillAppear: (() -> Void)? = { [weak self] in
    self?.updateValue()
  }
  
  // MARK: - Internal func
  
  func getAplicationVersion() -> String {
    let appVersion = interactor.getAppVersion()
    let versionTitle = OChatStrings.SettingsScreenLocalization
      .State.Version.title
    return "\(versionTitle) \(appVersion)"
  }
}

// MARK: - SettingsScreenModuleInput

extension SettingsScreenPresenter: SettingsScreenModuleInput {}

// MARK: - SettingsScreenInteractorOutput

extension SettingsScreenPresenter: SettingsScreenInteractorOutput {}

// MARK: - SettingsScreenFactoryOutput

extension SettingsScreenPresenter: SettingsScreenFactoryOutput {
  func copyOnionAdress() {
    // TODO: -
  }
  
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
    interactor.getIsAccessCodeEnabled { [weak self] isEnabled in
      self?.statePasscodeAndFaceIDValue = isEnabled
    }
    
    stateCurrentLanguage = interactor.getCurrentLanguage()
  }
  
  func initialSetup() {
    let languageValue = factory.createLanguageValue(from: stateCurrentLanguage)
    
    interactor.getOnionAddress { [weak self] result in
      guard let self else {
        return
      }
      
      let onionAddress = try? result.get()
      stateSectionsModels = factory.createSecuritySectionsModels(
        passcodeAndFaceIDValue: statePasscodeAndFaceIDValue,
        messengerIsEnabled: stateMessengerIsEnabled,
        languageValue: languageValue,
        myOnionAddress: onionAddress ?? ""
      )
    }
  }
}

// MARK: - Constants

private enum Constants {}
