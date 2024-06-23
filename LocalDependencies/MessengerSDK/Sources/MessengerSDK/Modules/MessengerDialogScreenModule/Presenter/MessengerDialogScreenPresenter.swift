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
import SKFoundation

final class MessengerDialogScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  // MARK: - Initial chat state
  
  @Published var stateContactAdress = ""
  @Published var stateIsDeeplinkAdress = false
  @Published var stateContactAdressMaxLength = 76
  @Published var stateShowInitialTips = true
  @Published var stateIsCanResendInitialRequest = false
  @Published var stateSecondsUntilResendInitialRequestAllowed = 0
  
  // MARK: - Request chat state
  
  // MARK: - Chat state
  
  @Published var stateContactModel: ContactModel
  @Published var stateMessengeModels: [MessengeModel] = []
  @Published var stateInputMessengeText = ""
  @Published var stateInputMessengeTextMaxLength = 1_000
  
  // MARK: - Internal properties
  
  weak var moduleOutput: MessengerDialogScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: MessengerDialogScreenInteractorInput
  private let factory: MessengerDialogScreenFactoryInput
  private weak var deleteRightBarButton: SKBarButtonItem?
  private var barButtonView: SKBarButtonView?
  private var timer: Timer?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - dialogModel: Моделька с данными
  ///   - contactAdress: Адрес контакта
  init(interactor: MessengerDialogScreenInteractorInput,
       factory: MessengerDialogScreenFactoryInput,
       dialogModel: ContactModel?,
       contactAdress: String?) {
    self.interactor = interactor
    self.factory = factory
    stateContactAdress = contactAdress ?? (dialogModel?.toxAddress ?? "")
    stateIsDeeplinkAdress = contactAdress != nil
    let contact = dialogModel ?? factory.createInitialContact(address: contactAdress ?? "")
    stateContactModel = contact
    stateMessengeModels = contact.messenges
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else { return }
    initialSetup()
  }
  
  lazy var viewWillDisappear: (() -> Void)? = { [weak self] in
    guard let self else { return }
    moduleOutput?.messengerDialogWillDisappear()
    setUserIsTyping(text: "")
  }
  
  // MARK: - Internal func
  
  func removeMessage(id: String) {
    moduleOutput?.removeMessage(id: id, contact: stateContactModel)
  }
  
  func sendMessage() {
    guard !stateInputMessengeText.isEmpty else { return }
    let messenge = stateInputMessengeText
    var updatedContactModel = stateContactModel
    let messengeModel = MessengeModel(
      messageType: .own,
      messageStatus: .inProgress,
      message: messenge
    )
    
    stateMessengeModels.append(messengeModel)
    updatedContactModel.messenges.append(messengeModel)
    stateContactModel = updatedContactModel
    
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      moduleOutput?.sendMessage(messenge, contact: updatedContactModel)
    }
    stateInputMessengeText = ""
  }
  
  func sendInitiateChatFromDialog() {
    var updatedModel = stateContactModel
    updatedModel.toxAddress = stateContactAdress
    stateContactModel = updatedModel
    
    DispatchQueue.global().async { [weak self] in
      self?.moduleOutput?.sendInitiateChatFromDialog(contactModel: updatedModel)
    }
    
    updateCenterBarButtonView(isHidden: false)
  }
  
  func confirmRequestForDialog() {
    moduleOutput?.confirmRequestForDialog(contactModel: stateContactModel)
  }
  
  func cancelRequestForDialog() {
    moduleOutput?.cancelRequestForDialog(contactModel: stateContactModel)
    moduleOutput?.closeMessengerDialog()
  }
  
  func isInitialChatValidation() -> Bool {
    !stateContactAdress.isEmpty && stateContactAdress.count == stateContactAdressMaxLength
  }
  
  func isChatValidation() -> Bool {
    !stateInputMessengeText.isEmpty && stateContactModel.status == .online
  }
  
  func getInitialPlaceholder() -> String {
    factory.createInitialPlaceholder()
  }
  
  func getMainPlaceholder() -> String {
    factory.createMainPlaceholder()
  }
  
  func getInitialHintModel() -> MessengerDialogHintModel {
    factory.createInitialHintModel()
  }
  
  func getRequestHintModel() -> MessengerDialogHintModel {
    factory.createRequestHintModel()
  }
  
  func getRequestButtonCancelTitle() -> String {
    factory.createRequestButtonCancelTitle()
  }
  
  func isInitialAddressEntryState() -> Bool {
    stateContactModel.status == .initialChat &&
    (stateContactModel.toxAddress.isNilOrEmpty || stateIsDeeplinkAdress)
  }
  
  func isInitialWaitConfirmState() -> Bool {
    stateContactModel.status == .initialChat && !stateContactModel.toxAddress.isNilOrEmpty || (stateContactModel.encryptionPublicKey ?? "").isEmpty
  }
  
  func isRequestChatState() -> Bool {
    stateContactModel.status == .requestChat
  }
  
  func startScheduleResendInitialRequest() {
    // Устанавливаем начальное состояние
    stateIsCanResendInitialRequest = false
    stateSecondsUntilResendInitialRequestAllowed = 30
    
    // Инвалидируем предыдущий таймер, если он существует
    timer?.invalidate()
    
    // Запускаем новый таймер, который обновляется каждую секунду
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
      guard let self = self else { return }
      
      // Уменьшаем количество оставшихся секунд
      self.stateSecondsUntilResendInitialRequestAllowed -= 1
      
      // Если отсчёт завершён, обновляем состояние и останавливаем таймер
      if self.stateSecondsUntilResendInitialRequestAllowed <= 0 {
        self.stateIsCanResendInitialRequest = true
        timer.invalidate()
      }
    }
  }
  
  func setUserIsTyping(text: String) {
    guard let toxPublicKey = stateContactModel.toxPublicKey else {
      return
    }
    
    DispatchQueue.global().async { [weak self] in
      self?.moduleOutput?.setUserIsTyping(!text.isEmpty, to: toxPublicKey, completion: { _ in })
    }
  }
}

// MARK: - MessengerDialogScreenModuleInput

extension MessengerDialogScreenPresenter: MessengerDialogScreenModuleInput {
  func updateDialog() {
    interactor.getNewContactModels(stateContactModel) { [weak self] contactModel in
      guard let self else { return }
      
      if isWelcomeMessageAllowed(contactModel: contactModel) {
        addWelcomeMessage(contactModel: contactModel)
        return
      }
      
      self.stateContactModel = contactModel
      self.stateMessengeModels = contactModel.messenges
      updateCenterBarButtonView(isHidden: false)
    }
  }
}

// MARK: - MessengerDialogScreenInteractorOutput

extension MessengerDialogScreenPresenter: MessengerDialogScreenInteractorOutput {}

// MARK: - MessengerDialogScreenFactoryOutput

extension MessengerDialogScreenPresenter: MessengerDialogScreenFactoryOutput {}

// MARK: - SceneViewModel

extension MessengerDialogScreenPresenter: SceneViewModel {
  var isEndEditing: Bool {
    true
  }
  
  var centerBarButtonItem: SKBarButtonViewType? {
    .widgetCryptoView(barButtonView)
  }
}

// MARK: - Private

private extension MessengerDialogScreenPresenter {
  func initialSetup() {
    markMessageAsRead(contactModel: stateContactModel)
    
    barButtonView = SKBarButtonView(
      .init(
        leftImage: nil,
        centerText: nil,
        rightImage: nil,
        isEnabled: false,
        action: {}
      )
    )
    
    updateCenterBarButtonView(isHidden: isInitialAddressEntryState() || isRequestChatState())
    if isInitialWaitConfirmState() {
      startScheduleResendInitialRequest()
    }
  }
  
  func markMessageAsRead(contactModel: ContactModel) {
    guard contactModel.status != .initialChat else {
      return
    }
    var contactUpdated = contactModel
    if contactUpdated.isNewMessagesAvailable {
      contactUpdated.isNewMessagesAvailable = false
    }
    
    DispatchQueue.global().async { [weak self] in
      self?.moduleOutput?.saveContactModel(contactUpdated)
    }
  }
  
  func updateCenterBarButtonView(isHidden: Bool) {
    var title = stateContactAdress
    if let toxAddress = stateContactModel.toxAddress, !toxAddress.isEmpty {
      title = toxAddress
    }
    
    let toxAddress = stateContactModel.toxAddress
    let stateContactAdress = stateContactAdress
    barButtonView?.isHidden = isHidden
    barButtonView?.iconLeftView.image = stateContactModel.status.imageStatus
    barButtonView?.labelView.text = factory.createHeaderTitleFrom(title)
  }
  
  func addWelcomeMessage(contactModel: ContactModel) {
    var contactUpdated = contactModel
    let publicKeyIsEmpty = (stateContactModel.encryptionPublicKey ?? "").isEmpty
    
    let sender = "Поздравляем! Вас успешно добавили в контакты. Теперь дождитесь, когда ваш новый контакт вам напишет"
    let receiver = "Поздравляем! Вы успешно добавили контакт. Пожалуйста, отправьте сообщение первым, чтобы начать общение"
    
    contactUpdated.messenges.append(
      .init(
        messageType: .systemSuccess,
        messageStatus: .delivered,
        message: publicKeyIsEmpty ? sender : receiver
      )
    )
    
    DispatchQueue.global().async { [weak self] in
      self?.moduleOutput?.saveContactModel(contactUpdated)
    }
  }
  
  func isWelcomeMessageAllowed(contactModel: ContactModel) -> Bool {
    let isMessengesIsEmpty = contactModel.messenges.filter({ !$0.messageType.isSystem }).isEmpty
    let isContainsSystemMessengeSuccess = contactModel.messenges.contains(where: ({
      $0.messageType == .systemSuccess
    }))
    return isMessengesIsEmpty && !isContainsSystemMessengeSuccess && contactModel.status == .online
  }
}

// MARK: - Constants

private enum Constants {}
