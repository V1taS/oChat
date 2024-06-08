//
//  MessengerDialogScreenPresenter.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class MessengerDialogScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateInputMessengeText = ""
  @Published var stateIsEnabledRightButton = true
  @Published var stateBottomHelper: String?
  @Published var stateIsErrorInputText = false
  @Published var stateIsEnabledInputText = true
  @Published var stateMaxLengthInputText = 100
  
  @Published var stateMessengeModels: [MessengeModel] = []
  @Published var stateContactModel: ContactModel
  @Published var stateCostOfSendingMessage: String?
  
  @Published var stateKeyExchangeTitle: String = ""
  @Published var stateKeyExchangeIsShow = false
  @Published var stateChatingTitle: String = ""
  
  // MARK: - Internal properties
  
  weak var moduleOutput: MessengerDialogScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: MessengerDialogScreenInteractorInput
  private let factory: MessengerDialogScreenFactoryInput
  private var keyExchangeSecondsLeft = 100
  private var chatingSecondsLeft = 100
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - dialogModel: Моделька с данными
  init(interactor: MessengerDialogScreenInteractorInput,
       factory: MessengerDialogScreenFactoryInput,
       dialogModel: ContactModel) {
    self.interactor = interactor
    self.factory = factory
    self.stateContactModel = dialogModel
    self.stateMessengeModels = configureMessengeModel(dialogModel.messenges)
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else { return }
    
    timerForKeyExchangeTitle()
    timerForChating()
  }

  lazy var viewWillDisappear: (() -> Void)? = { [weak self] in
    guard let self else { return }
    moduleOutput?.messengerDialogWillDisappear()
  }
  
  // MARK: - Internal func
  
  func sendMessage() {
    let messenge = stateInputMessengeText
    let contactModel = stateContactModel
    let messengeModel = MessengeModel(
      messageType: .own,
      messageStatus: .inProgress,
      message: messenge
    )
    
    stateMessengeModels.append(messengeModel)
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      moduleOutput?.sendMessage(messenge, contact: contactModel)
    }
  }
  
  func sendInitiateChatFromDialog() {
    keyExchangeSecondsLeft = 100
    timerForKeyExchangeTitle()
    
    interactor.showNotification(.positive(title: "Запрос на переписку отправлен"))
    let contactModel = stateContactModel
    moduleOutput?.sendInitiateChatFromDialog(onionAddress: contactModel.onionAddress ?? "")
  }
  
  func getPlaceholder() -> String {
    factory.createPlaceholder()
  }
  
  /// Прошел валидацию запроса
  func isValidationRequested() -> Bool {
    true
//    return stateContactModel.encryptionPublicKey != nil
  }
}

// MARK: - MessengerDialogScreenModuleInput

extension MessengerDialogScreenPresenter: MessengerDialogScreenModuleInput {
  func updateDialog() {
    interactor.getNewContactModels(stateContactModel) { [weak self] contactModel in
      guard let self else { return }
      self.stateMessengeModels = configureMessengeModel(contactModel.messenges)
      self.stateContactModel = contactModel
    }
  }
  
  func userChoseToDeleteContact() {
    moduleOutput?.contactHasBeenDeleted(stateContactModel)
  }
}

// MARK: - MessengerDialogScreenInteractorOutput

extension MessengerDialogScreenPresenter: MessengerDialogScreenInteractorOutput {}

// MARK: - MessengerDialogScreenFactoryOutput

extension MessengerDialogScreenPresenter: MessengerDialogScreenFactoryOutput {}

// MARK: - SceneViewModel

extension MessengerDialogScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle(dialogModel: stateContactModel)
  }
  
  var isEndEditing: Bool {
    true
  }
  
  var rightBarButtonItem: SKBarButtonItem? {
    .init(.delete(action: { [weak self] in
      self?.moduleOutput?.deleteContactButtonTapped()
    }))
  }
}

// MARK: - Private

private extension MessengerDialogScreenPresenter {
  func configureMessengeModel(_ encryptMessengeModels: [MessengeModel]) -> [MessengeModel] {
    let decrypttMessengeModels = encryptMessengeModels.compactMap { messengeModel in
      var updatedMessengeModel = messengeModel
      updatedMessengeModel.message = interactor.decrypt(updatedMessengeModel.message) ?? ""
      return updatedMessengeModel
    }
    return decrypttMessengeModels.filter { !$0.message.isEmpty }
  }
  
  func timerForKeyExchangeTitle() {
    if self.stateContactModel.encryptionPublicKey == nil {
      Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
        guard let self = self else { return }
        if keyExchangeSecondsLeft > .zero {
          self.stateKeyExchangeTitle = "Повторно отправить запрос можно через \(keyExchangeSecondsLeft) сек."
          self.stateKeyExchangeIsShow = false
          keyExchangeSecondsLeft -= 1
        } else {
          self.stateKeyExchangeTitle = "Запрос можно отправить сейчас"
          self.stateKeyExchangeIsShow = true
          timer.invalidate()
        }
      }
    }
  }
  
  func timerForChating() {
    if stateMessengeModels.last?.messageStatus == .inProgress {
      Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
        guard let self = self else { return }
        if chatingSecondsLeft > .zero {
          self.stateChatingTitle = "Повторно отправить можно через \(chatingSecondsLeft) сек."
          self.stateIsEnabledRightButton = false
          chatingSecondsLeft -= 1
        } else {
          self.stateChatingTitle = ""
          self.stateIsEnabledRightButton = true
          chatingSecondsLeft = 100
          timer.invalidate()
          moduleOutput?.removeDialogMessage(
            stateMessengeModels.last?.message,
            contact: stateContactModel,
            completion: { [weak self] in
              guard let self = self else { return }
              updateDialog()
            }
          )
        }
      }
    }
  }
}

// MARK: - Constants

private enum Constants {}
