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
  
  /// Язык в приложении
  @Published var stateCurrentLanguage: AppLanguageType = .english
  @Published var stateTopWidgetModels: [WidgetCryptoView.Model] = []
  @Published var stateBottomWidgetModels: [WidgetCryptoView.Model] = []
  
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
    Task { [weak self] in
      await self?.updateContent()
    }
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

extension SettingsScreenPresenter: SettingsScreenModuleInput {
  func deleteAllData() async -> Bool {
    await interactor.deleteAllData()
  }
}

// MARK: - SettingsScreenInteractorOutput

extension SettingsScreenPresenter: SettingsScreenInteractorOutput {}

// MARK: - SettingsScreenFactoryOutput

extension SettingsScreenPresenter: SettingsScreenFactoryOutput {
  func userIntentionExit() {
    moduleOutput?.userIntentionExit()
  }
  
  func userIntentionDeleteAndExit() {
    moduleOutput?.userIntentionDeleteAndExit()
  }
  
  func userSelectFeedBack() {
    moduleOutput?.userSelectFeedBack()
  }
  
  func openMyProfileSection() {
    moduleOutput?.openMyProfileSection()
  }
  
  func openPasscodeAndFaceIDSection() {
    moduleOutput?.openPasscodeAndFaceIDSection()
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
  @MainActor
  func updateContent() async {
    stateCurrentLanguage = interactor.getCurrentLanguage()
    let appSettingsModel = await interactor.getMessengerModel().appSettingsModel
    let languageValue = factory.createLanguageValue(from: stateCurrentLanguage)
    
    stateTopWidgetModels = factory.createTopWidgetModels(appSettingsModel, languageValue: languageValue)
    stateBottomWidgetModels = factory.createBottomWidgetModels(appSettingsModel)
  }
}

// MARK: - Constants

private enum Constants {}
