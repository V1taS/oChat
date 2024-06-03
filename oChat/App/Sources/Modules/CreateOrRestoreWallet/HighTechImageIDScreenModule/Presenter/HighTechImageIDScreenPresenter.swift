//
//  HighTechImageIDScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import PhotosUI
import Photos
import SKAbstractions

final class HighTechImageIDScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateIsSaveImageID = false
  @Published var stateIsConfirmationRequirements = false
  @Published var stateSaveImageIDButtonTitle = OChatStrings
    .HighTechImageIDScreenLocalization.State.Button.SaveImageID.title
  @Published var stateIsDisabledPhotosPicker = false
  @Published var stateCurrentStateScreen: HighTechImageIDScreenState
  
  @Published var stateImageID: Data?
  @Published var modifiedImageID: Data?
  @Published var stateFirstInputText = ""
  @Published var stateSecondInputText = ""
  @Published var stateErrorHelperText: String?
  @Published var stateIsErrorHelperText: Bool = false
  
  // MARK: - Internal properties
  
  weak var moduleOutput: HighTechImageIDScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: HighTechImageIDScreenInteractorInput
  private let factory: HighTechImageIDScreenFactoryInput
  private var walletModel: WalletModel?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - state: Состояние экрана
  ///   - walletModel: Модель кошелька
  init(interactor: HighTechImageIDScreenInteractorInput,
       factory: HighTechImageIDScreenFactoryInput,
       state: HighTechImageIDScreenState,
       walletModel: WalletModel?) {
    self.interactor = interactor
    self.factory = factory
    self.stateCurrentStateScreen = state
    self.walletModel = walletModel
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
  
  func setImageIDState() {
    stateCurrentStateScreen = factory.setNewStateScreen(from: stateCurrentStateScreen, to: .passCodeImage)
    stateIsDisabledPhotosPicker = factory.setIsDisabledPhotosPicker(stateCurrentStateScreen)
  }
  
  func setImageID(_ image: PhotosPickerItem?) async {
    do {
      let imageData = try await image?.loadTransferable(type: Data.self)
      stateImageID = imageData
    } catch let error {
      interactor.showNotification(.negative(title: error.localizedDescription))
    }
  }
  
  func createAdditionProtectionModel() -> WidgetCryptoView.Model {
    return factory.createAdditionProtectionModel(
      stateCurrentStateScreen,
      firstInputText: stateFirstInputText,
      secondInputText: stateSecondInputText
    )
  }
  
  func setIsSaveImageID(value: Bool) {
    stateIsSaveImageID = value
  }
  
  func saveImageToGallery() {
    moduleOutput?.saveHighTechImageIDToGallery(modifiedImageID)
  }
  
  func createButtonTitle() -> String {
    factory.createButtonTitle(stateCurrentStateScreen)
  }
  
  func isValidationMainButton() -> Bool {
    factory.isValidationMainButton(
      stateCurrentStateScreen,
      firstInputText: stateFirstInputText,
      secondInputText: stateSecondInputText,
      isSaveImageID: stateIsSaveImageID,
      isConfirmationRequirements: stateIsConfirmationRequirements
    )
  }
  
  func continueButtonTapped() {
    switch stateCurrentStateScreen {
    case let .generateImageID(result):
      switch result {
      case .initialState:
        stateCurrentStateScreen = factory.setNewStateScreen(
          from: stateCurrentStateScreen,
          to: .passCodeImage
        )
      case .passCodeImage:
        stateCurrentStateScreen = factory.setNewStateScreen(
          from: stateCurrentStateScreen,
          to: .startUploadImage
        )
        
        embedSeedPhraseIntoImage()
      case .startUploadImage:
        stateCurrentStateScreen = factory.setNewStateScreen(
          from: stateCurrentStateScreen,
          to: .finish
        )
      case .finish:
        guard let walletModel else {
          somethingWentWrong()
          return
        }
        interactor.saveWallet(walletModel: walletModel) { [weak self] in
          guard let self else {
            return
          }
          
          moduleOutput?.successCreatedHighTechImageIDScreen()
        }
      }
    case let .loginImageID(result):
      switch result {
      case .initialState:
        stateCurrentStateScreen = factory.setNewStateScreen(
          from: stateCurrentStateScreen,
          to: .passCodeImage
        )
      case .passCodeImage:
        stateCurrentStateScreen = factory.setNewStateScreen(
          from: stateCurrentStateScreen,
          to: .startUploadImage
        )
        
        extractSeedPhraseFromImage()
      case .startUploadImage:
        stateCurrentStateScreen = factory.setNewStateScreen(
          from: stateCurrentStateScreen,
          to: .finish
        )
      case .finish:
        guard let walletModel else {
          somethingWentWrong()
          return
        }
        interactor.saveWallet(walletModel: walletModel) { [weak self] in
          guard let self else {
            return
          }
          
          moduleOutput?.successLoginHighTechImageIDScreen()
        }
      }
    }
  }
  
  func createTermsOfAgreementTitle() -> String {
    factory.createTermsOfAgreementTitle()
  }
  
  func confirmationRequirements(value: Bool) {
    stateIsConfirmationRequirements = value
  }
  
  func createStepDescription() -> String {
    factory.createStepDescription(stateCurrentStateScreen)
  }
  
  func createHeaderDescription() -> String {
    factory.createHeaderDescription(stateCurrentStateScreen)
  }
}

// MARK: - HighTechImageIDScreenModuleInput

extension HighTechImageIDScreenPresenter: HighTechImageIDScreenModuleInput {}

// MARK: - HighTechImageIDScreenInteractorOutput

extension HighTechImageIDScreenPresenter: HighTechImageIDScreenInteractorOutput {
  func didReceiveNotDefined() {
    interactor.showNotification(
      .negative(
        title: OChatStrings.HighTechImageIDScreenLocalization
          .State.Error.NotDefined.title
      )
    )
    
    setInitialState()
  }
  
  func didReceiveDataTooBig() {
    interactor.showNotification(
      .negative(
        title: OChatStrings.HighTechImageIDScreenLocalization
          .State.Error.DataTooBig.title
      )
    )
    
    setInitialState()
  }
  
  func didReceiveImageTooSmall() {
    interactor.showNotification(
      .negative(
        title: OChatStrings.HighTechImageIDScreenLocalization
          .State.Error.ImageTooSmall.title
      )
    )
    
    setInitialState()
  }
  
  func didReceiveNoDataInImage() {
    interactor.showNotification(
      .negative(
        title: OChatStrings.HighTechImageIDScreenLocalization
          .State.Error.NoDataInImage.title
      )
    )
    
    setInitialState()
  }
  
  func somethingWentWrong() {
    showSomethingWentWrong()
  }
}

// MARK: - HighTechImageIDScreenFactoryOutput

extension HighTechImageIDScreenPresenter: HighTechImageIDScreenFactoryOutput {
  func changeFirstInputText(text: String) {
    stateFirstInputText = text
  }
  
  func changeSecondInputText(text: String) {
    stateSecondInputText = text
  }
  
  func openInfoImageIDSheet() {
    moduleOutput?.openInfoImageIDSheet()
  }
}

// MARK: - SceneViewModel

extension HighTechImageIDScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle(stateCurrentStateScreen)
  }
  
  var leftBarButtonItem: SKBarButtonItem? {
    .init(.close(action: { [weak self] in
      self?.moduleOutput?.closeButtonHighTechImageIDScreenTapped()
    }))
  }
  
  var isEndEditing: Bool {
    true
  }
}

// MARK: - Private

private extension HighTechImageIDScreenPresenter {
  func setInitialState() {
    stateCurrentStateScreen = factory.setNewStateScreen(from: stateCurrentStateScreen, to: .initialState)
    stateIsDisabledPhotosPicker = factory.setIsDisabledPhotosPicker(stateCurrentStateScreen)
    stateFirstInputText = ""
    stateSecondInputText = ""
  }
  
  func extractSeedPhraseFromImage() {
    guard let stateImageID,
          !stateFirstInputText.isEmpty else {
      showSomethingWentWrong()
      return
    }
    
    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in
      guard let self else {
        return
      }
      
      interactor.extractSeedPhraseFromImage(
        passcode: stateFirstInputText,
        in: stateImageID) { [weak self] seedPhrase in
          guard let self,
                let seedPhrase,
                interactor.isValidMnemonic(seedPhrase) else {
            self?.showSomethingWentWrong()
            return
          }
          
          interactor.createWallet(
            seedPhrase: seedPhrase,
            imageID: modifiedImageID ?? stateImageID
          ) { [weak self] walletModel in
            guard let self else {
              return
            }
            
            self.walletModel = walletModel
            self.stateCurrentStateScreen = factory.setNewStateScreen(
              from: self.stateCurrentStateScreen,
              to: .finish
            )
          }
        }
    }
  }
  
  func embedSeedPhraseIntoImage() {
    guard let walletModel,
          let stateImageID,
          !stateSecondInputText.isEmpty else {
      showSomethingWentWrong()
      return
    }
    
    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in
      guard let self else {
        return
      }
      
      interactor.embedSeedPhraseIntoImage(
        seedPhrase: walletModel.seedPhrase,
        passcode: stateSecondInputText,
        in: stateImageID) { [weak self] imageData in
          guard let self else {
            return
          }
          
          self.modifiedImageID = imageData
          self.stateCurrentStateScreen = factory.setNewStateScreen(
            from: self.stateCurrentStateScreen,
            to: .finish
          )
        }
    }
  }
  
  func showSomethingWentWrong() {
    interactor.showNotification(
      .negative(
        title: OChatStrings.HighTechImageIDScreenLocalization
          .State.Error.SomethingWentWrong.title
      )
    )
    setInitialState()
  }
}

// MARK: - Constants

private enum Constants {}
