//
//  MessengerListScreenModulePresenter.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions
import SKFoundation
import UIKit
import SKManagers

final class MessengerListScreenModulePresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateWidgetModels: [WidgetCryptoView.Model] = []
  @Published var stateIsNotificationsEnabled = true
  
  // MARK: - Internal properties
  
  weak var moduleOutput: MessengerListScreenModuleOutput?
  let interactor: MessengerListScreenModuleInteractorInput
  let factory: MessengerListScreenModuleFactoryInput
  let incomingDataManager: IIncomingDataManager
  var centerBarButtonView: SKBarButtonView?
  var rightBarLockButton: SKBarButtonItem?
  var rightBarWriteButton: SKBarButtonItem?
  let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
  
  // MARK: - Private properties
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - incomingDataManager: Менеджер по входящим данным
  init(
    interactor: MessengerListScreenModuleInteractorInput,
    factory: MessengerListScreenModuleFactoryInput,
    incomingDataManager: IIncomingDataManager
  ) {
    self.interactor = interactor
    self.factory = factory
    self.incomingDataManager = incomingDataManager
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else { return }
    
    initialSetup()
  }
  
  lazy var viewWillAppear: (() -> Void)? = { [weak self] in
    guard let self else { return }
    
    Task { [weak self] in
      guard let self else { return }
      await checkAccessDemo()
    }
  }
  
  // MARK: - Internal func
  
  func clearContact(index: Int) {
    Task { [weak self] in
      guard let self else { return }
      
      let contactModels = await interactor.getContactModels()
      let contactModel = contactModels[index]
      await interactor.removeMessenges(contactModel)
      
      await interactor.addMessenge(
        contactModel.id,
        .init(
          messageType: .systemAttention,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization
            .Message.SuccessfullyClearedAllChat.title,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        )
      )
      
      moduleOutput?.dataModelHasBeenUpdated()
      await updateListContacts()
    }
  }
  
  func requestNotification() {
    Task { [weak self] in
      guard let self else { return }
      stateIsNotificationsEnabled = await interactor.requestNotification()
    }
  }
  
  func updateRedDotToTabBar(contactModels: [ContactModel]) {
    let newMessages = contactModels.filter({ $0.isNewMessagesAvailable })
    let redDotToTabBarText: String? = newMessages.isEmpty ? nil : "\(newMessages.count)"
    interactor.setRedDotToTabBar(value: redDotToTabBarText)
  }
  
  func clearHistoryStored() async {
    let contactModels = await interactor.getContactModels()
    for contact in contactModels where !contact.isChatHistoryStored {
      let messages = await interactor.getMessengeModelsFor(contact.id)
      let appPassword = await interactor.getAppSettingsModel().appPassword
      let fiveMinutesAgo = Date().addingTimeInterval(-Secrets.fiveMinutesAgoInSeconds)
      
      // Код продолжает выполняться, если прошло более 5 минут (300 Секунд) с момента последнего сообщения
      // Если пароль установлен, то проверяем активность сессии, иначе продолжаем выполнение кода
      guard let lastMessageDate = messages.last?.date,
            lastMessageDate <= fiveMinutesAgo,
            appPassword != nil && interactor.isSessionActive() || appPassword == nil else {
        continue
      }
      
      await interactor.removeMessenges(contact)
      await interactor.addMessenge(
        contact.id,
        .init(
          messageType: .systemAttention,
          messageStatus: .sent,
          message: OChatStrings.MessengerListScreenModuleLocalization
            .Message.ClearHistoryStored.title,
          replyMessageText: nil,
          images: [],
          videos: [],
          recording: nil
        )
      )
    }
    await updateListContacts()
    moduleOutput?.dataModelHasBeenUpdated()
  }
}

// MARK: - MessengerListScreenModuleModuleInput

extension MessengerListScreenModulePresenter: MessengerListScreenModuleModuleInput {
  func removeContactModels(_ contactModel: SKAbstractions.ContactModel) async {
    await interactor.removeContactModels(contactModel)
    moduleOutput?.dataModelHasBeenUpdated()
    await updateListContacts()
  }
  
  func getAppSettingsModel() async -> SKAbstractions.AppSettingsModel {
    await interactor.getAppSettingsModel()
  }
  
  func removeContact(index: Int) async {
    stateWidgetModels.remove(at: index)
    let contactModels = await interactor.getContactModels()
    let contactModel = contactModels[index]
    await interactor.removeContactModels(contactModel)
    moduleOutput?.dataModelHasBeenUpdated()
    await updateListContacts()
  }
  
  func sendPushNotification(contact: ContactModel) async {
    await interactor.sendPushNotification(contact: contact)
  }
  
  func setUserIsTyping(
    _ isTyping: Bool,
    to toxPublicKey: String
  ) async -> Result<Void, any Error> {
    await interactor.setUserIsTyping(isTyping, to: toxPublicKey)
  }
  
  func saveContactModel(_ model: SKAbstractions.ContactModel) async {
    await interactor.saveContactModel(model)
    await updateListContacts()
  }
  
  func sendInitiateChat(contactModel: ContactModel) async {
    guard let updatedContactModel = await checkingContactPublicKey(contact: contactModel) else {
      return
    }
    
    await sendInitiateChatNetworkRequest(contact: updatedContactModel)
    moduleOutput?.dataModelHasBeenUpdated()
    await updateListContacts()
  }
  
  func confirmRequestForDialog(contactModel: ContactModel) async {
    guard let toxPublicKey = contactModel.toxPublicKey else {
      interactor.showNotification(
        .negative(
          title: OChatStrings.MessengerListScreenModuleLocalization
            .Notification.PublicKeyMissing.title
        )
      )
      return
    }
    
    if let toxPublicKey = await interactor.confirmFriendRequest(with: toxPublicKey) {
      var updatedContactModel = contactModel
      updatedContactModel.status = .online
      await interactor.saveContactModel(updatedContactModel)
      moduleOutput?.dataModelHasBeenUpdated()
      await updateListContacts()
    } else {
      interactor.showNotification(
        .negative(
          title: OChatStrings.MessengerListScreenModuleLocalization
            .Notification.ErrorAddingContact.title
        )
      )
      await interactor.removeContactModels(contactModel)
      moduleOutput?.dataModelHasBeenUpdated()
      await updateListContacts()
    }
  }
  
  func cancelRequestForDialog(contactModel: ContactModel) async {
    await removeContactModels(contactModel)
    interactor.showNotification(
      .positive(
        title: OChatStrings.MessengerListScreenModuleLocalization
          .Notification.ContactHasBeenDeleted.title
      )
    )
  }
  
  func sendMessage(contact: ContactModel) async {
    guard contact.status == .online else {
      interactor.showNotification(
        .negative(
          title: OChatStrings.MessengerListScreenModuleLocalization
            .Notification.ContactIsOffline.title
        )
      )
      return
    }
    
    guard let updatedContactModel = await checkingContactPublicKey(contact: contact) else {
      interactor.showNotification(
        .negative(
          title: OChatStrings.MessengerListScreenModuleLocalization
            .Notification.PublicKeyMissing.title
        )
      )
      return
    }
    
    switch await sendMessageNetworkRequest(contact: updatedContactModel) {
    case let .success(messageId):
      if let messageId {
        await updateContactStatus(
          contact: contact,
          status: .sending,
          messageId: UInt32(messageId)
        )
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
          Task { [weak self] in
            guard let self else { return }
            let contactModel = await interactor.getContactModelsFrom(toxAddress: contact.toxAddress ?? "")
            
            guard let contactModel else { return }
            var updatedMessenges = await interactor.getListMessengeModels(contactModel)
            let messageId = UInt32(messageId)
            
            if let messengesIndex = updatedMessenges.firstIndex(where: { $0.tempMessageID == messageId }) {
              updatedMessenges[messengesIndex].messageStatus = .failed
              updatedMessenges[messengesIndex].tempMessageID = nil
              await interactor.updateMessenge(contactModel, updatedMessenges[messengesIndex])
              await updateListContacts()
              moduleOutput?.dataModelHasBeenUpdated()
            }
          }
        }
      }
      moduleOutput?.dataModelHasBeenUpdated()
      await updateListContacts()
    case .failure:
      await updateContactStatus(contact: contact, status: .failed, messageId: nil)
      moduleOutput?.dataModelHasBeenUpdated()
      await updateListContacts()
    }
  }
  
  func getContactModelsFrom(toxAddress: String) async -> ContactModel? {
    await interactor.getContactModelsFrom(toxAddress: toxAddress)
  }
  
  func removeMessage(id: String, contact: ContactModel) async {
    await interactor.removeMessenge(contact, id)
    moduleOutput?.dataModelHasBeenUpdated()
    await updateListContacts()
  }
  
  @MainActor
  func updateListContacts() async {
    updateIsNotificationsEnabled()
    let contactModels = await interactor.getContactModels()
    updateRedDotToTabBar(contactModels: contactModels)
    await updateWidgetsOnMainScreen(contactModels: contactModels)
  }
}

// MARK: - MessengerListScreenModuleInteractorOutput

extension MessengerListScreenModulePresenter: MessengerListScreenModuleInteractorOutput {}

// MARK: - MessengerListScreenModuleFactoryOutput

extension MessengerListScreenModulePresenter: MessengerListScreenModuleFactoryOutput {
  func openMessengerDialogScreen(dialogModel: ContactModel) async {
    await moduleOutput?.openMessengerDialogScreen(
      dialogModel: dialogModel
    )
  }
}

// MARK: - SceneViewModel

extension MessengerListScreenModulePresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
  
  var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
    .always
  }
  
  var rightBarButtonItems: [SKBarButtonItem] {
    [
      .init(
        .lock(
          action: {
            Task { @MainActor [weak self] in
              guard let self else { return }
              let appSettingsModel = await interactor.getAppSettingsModel()
              
              if appSettingsModel.appPassword == nil {
                await moduleOutput?.setPasswordForApp()
              } else {
                await moduleOutput?.lockScreen()
                interactor.sessionDidExpire()
              }
            }
          }, buttonItem: { [weak self] buttonItem in
            self?.rightBarLockButton = buttonItem
          }
        )
      ),
      .init(
        .write(
          action: { [weak self] in
            self?.moduleOutput?.openNewMessengeScreen(
              contactAdress: nil
            )
          },
          buttonItem: { [weak self] buttonItem in
            self?.rightBarWriteButton = buttonItem
          }
        )
      )
    ]
  }
  
  var centerBarButtonItem: SKBarButtonViewType? {
    .widgetCryptoView(centerBarButtonView)
  }
}

// MARK: - Private

private extension MessengerListScreenModulePresenter {
  func updateWidgetsOnMainScreen(contactModels: [ContactModel]) async {
    var lastMessageDictionary: [String: String] = [:]
    for contactModel in contactModels {
      let lastMessage = await interactor.getListMessengeModels(contactModel).last?.message ?? ""
      lastMessageDictionary[contactModel.id] = lastMessage
    }
    stateWidgetModels = factory.createDialogWidgetModels(
      messengerDialogModels: contactModels,
      lastMessageDictionary: lastMessageDictionary
    )
  }
  
  func updateIsNotificationsEnabled() {
    Task {
      stateIsNotificationsEnabled = await interactor.isNotificationsEnabled()
    }
  }
  
  func initialSetup() {
    // Отключаем таймер простоя
    UIApplication.shared.isIdleTimerDisabled = true
    
    incomingDataManager.onAppDidBecomeActive = { [weak self] in
      self?.handleAppDidBecomeActive()
    }
    
    setupSKBarButtonView()
    incomingDataManagerSetup()
    
    Task {
      await interactor.clearAllMessengeTempID()
      await interactor.startPeriodicFriendStatusCheck {
        Task { [weak self] in
          guard let self else { return }
          await updateListContacts()
          moduleOutput?.dataModelHasBeenUpdated()
        }
      }
      await interactor.setSelfStatus(isOnline: true)
      await interactor.startTOXService()
      let contactModels = await interactor.getContactModels()
      await updateWidgetsOnMainScreen(contactModels: contactModels)
      await interactor.setAllContactsIsOffline()
      await interactor.setAllContactsNoTyping()
      let token = await interactor.getPushNotificationToken()
      if token == nil {
        await UIApplication.shared.registerForRemoteNotifications()
      }
      
      await updateListContacts()
      await interactor.passcodeNotSetInSystemIOSheck()
    }
    
    updateIsNotificationsEnabled()
  }
  
  func updateContactStatus(
    contact: ContactModel,
    status: MessengeModel.MessageStatus,
    messageId: UInt32?
  ) async {
    let listMessengeModels = await interactor.getListMessengeModels(contact)
    guard var updatedLastMessage = listMessengeModels.last else { return }
    updatedLastMessage.messageStatus = status
    
    if let messageId {
      updatedLastMessage.tempMessageID = messageId
    }
    
    await interactor.setStatus(contact, .online)
    await interactor.updateMessenge(contact, updatedLastMessage)
  }
  
  func setupSKBarButtonView() {
    centerBarButtonView = SKBarButtonView(
      .init(
        leftImage: nil,
        centerText: nil,
        rightImage: nil, // UIImage(systemName: "chevron.down")?
        // .withTintColor(SKStyleAsset.ghost.color, renderingMode: .alwaysTemplate),
        isEnabled: false,
        action: { [weak self] in
          self?.moduleOutput?.openPanelConnection()
        }
      )
    )
    
    Task { [weak self] in
      guard let self else { return }
      let appSettingsModel = await interactor.getAppSettingsModel()
      
      await MainActor.run { [weak self] in
        guard let self else { return }
        centerBarButtonView?.iconLeftView.image = appSettingsModel.myStatus.imageStatus
        centerBarButtonView?.labelView.text = appSettingsModel.myStatus.title
        rightBarWriteButton?.isEnabled = appSettingsModel.myStatus == .online
      }
    }
  }
  
  func createRequestModel(
    message: String?,
    messageID: String?,
    replyMessageText: String?,
    senderAddress: String?,
    senderLocalMeshAddress: String?,
    senderPublicKey: String?,
    senderToxPublicKey: String?,
    senderPushNotificationToken: String?
  ) async -> (recipientTorAddress: String, requestModel: MessengerNetworkRequestModel)? {
    guard let senderAddress else {
      interactor.showNotification(
        .negative(
          title: OChatStrings.MessengerListScreenModuleLocalization
            .Notification.NoRecipientAddress.title
        )
      )
      return nil
    }
    let appSettingsModel = await interactor.getAppSettingsModel()
    
    let requestModel = MessengerNetworkRequestModel(
      messageText: message,
      messageID: messageID,
      replyMessageText: replyMessageText,
      senderAddress: senderAddress,
      senderLocalMeshAddress: senderLocalMeshAddress ?? "",
      senderPublicKey: senderPublicKey,
      senderToxPublicKey: senderToxPublicKey,
      senderPushNotificationToken: senderPushNotificationToken,
      canSaveMedia: appSettingsModel.canSaveMedia,
      isChatHistoryStored: appSettingsModel.isChatHistoryStored
    )
    return (senderAddress, requestModel)
  }
  
  func checkingContactPublicKey(contact: ContactModel) async -> ContactModel? {
    guard let toxAddress = contact.toxAddress else {
      interactor.showNotification(
        .negative(
          title: OChatStrings.MessengerListScreenModuleLocalization
            .Notification.IncorrectContactAddress.title
        )
      )
      return nil
    }
    
    var updatedContactModel = contact
    if contact.toxPublicKey == nil {
      let toxPublicKey = interactor.getToxPublicKey(from: toxAddress)
      updatedContactModel.toxPublicKey = toxPublicKey
    }
    return updatedContactModel
  }
  
  func prepareAndEncryptDataForNetworkRequest(
    contact: ContactModel
  ) async -> (recipientTorAddress: String, requestModel: MessengerNetworkRequestModel)? {
    guard let senderPublicKey = interactor.publicKey(from: interactor.getDeviceIdentifier()) else {
      interactor.showNotification(
        .negative(
          title: OChatStrings.MessengerListScreenModuleLocalization
            .Notification.FailedCreatePublicKey.title
        )
      )
      return nil
    }
    
    var message = ""
    var messageID = ""
    var replyMessageText: String?
    
    if let messengeModel = await interactor.getListMessengeModels(contact).last,
       messengeModel.messageStatus == .sending {
      message = messengeModel.message
      messageID = messengeModel.id
      replyMessageText = messengeModel.replyMessageText
    }
    
    let pushNotificationToken = await interactor.getPushNotificationToken()
    await interactor.saveContactModel(contact)
    var messageForSend = ""
    var senderPushNotificationTokenForSend: String?
    
    if let encryptionPublicKey = contact.encryptionPublicKey {
      let messageEncrypt = interactor.encrypt(message, publicKey: encryptionPublicKey)
      messageForSend = messageEncrypt ?? ""
    }
    
    if let pushNotificationToken, let encryptionPublicKey = contact.encryptionPublicKey {
      let pushNotificationTokenEncrypt = interactor.encrypt(
        pushNotificationToken,
        publicKey: encryptionPublicKey
      )
      senderPushNotificationTokenForSend = pushNotificationTokenEncrypt
    }
    
    let toxAddress = await interactor.getToxAddress()
    let toxPublicKey = await interactor.getToxPublicKey()
    return await createRequestModel(
      message: messageForSend,
      messageID: messageID,
      replyMessageText: replyMessageText,
      senderAddress: toxAddress,
      senderLocalMeshAddress: nil,
      senderPublicKey: senderPublicKey,
      senderToxPublicKey: toxPublicKey,
      senderPushNotificationToken: senderPushNotificationTokenForSend
    )
  }
  
  @discardableResult
  func sendInitiateChatNetworkRequest(contact: ContactModel) async -> Result<Void, Error> {
    guard let networkRequest = await prepareAndEncryptDataForNetworkRequest(contact: contact) else {
      return .failure(URLError(.unknown))
    }
    let (senderAddress, requestModel) = networkRequest
    guard let toxAddress = contact.toxAddress else {
      return .failure(URLError(.unknown))
    }
    
    if let contactID = await interactor.initialChat(senderAddress: toxAddress, messengerRequest: requestModel) {
      return .success(())
    }
    return .failure(URLError(.unknown))
  }
  
  func sendMessageNetworkRequest(contact: ContactModel) async -> Result<Int32?, Error> {
    guard let toxPublicKey = contact.toxPublicKey,
          let networkRequest = await prepareAndEncryptDataForNetworkRequest(contact: contact),
          let encryptionPublicKey = contact.encryptionPublicKey else {
      return .failure(URLError(.unknown))
    }
    let (recipientTorAddress, requestModel) = networkRequest
    let listMessenge = await interactor.getListMessengeModels(contact)
    let messengeIndex = listMessenge.firstIndex(where: {
      $0.id == listMessenge.last?.id
    })
    
    if let messengeIndex,
       !listMessenge[messengeIndex].videos.isEmpty ||
        !listMessenge[messengeIndex].images.isEmpty ||
        listMessenge[messengeIndex].recording != nil {
      var files: [URL?] = []
      
      listMessenge[messengeIndex].videos.forEach { files.append($0.full) }
      listMessenge[messengeIndex].images.forEach { files.append($0.full) }
      
      await interactor.sendFile(
        toxPublicKey: toxPublicKey,
        recipientPublicKey: encryptionPublicKey,
        recordModel: listMessenge[messengeIndex].recording,
        messengerRequest: requestModel,
        files: files.compactMap({ $0 })
      )
      return .success(nil)
    }
    
    if let messageText = requestModel.messageText, messageText.count > 300 {
      await interactor.sendFile(
        toxPublicKey: toxPublicKey,
        recipientPublicKey: encryptionPublicKey,
        recordModel: nil,
        messengerRequest: requestModel,
        files: []
      )
      return .success(nil)
    }
    
    if let messageID = await interactor.sendMessage(
      toxPublicKey: toxPublicKey,
      messengerRequest: requestModel
    ) {
      let listMessenge = await interactor.getListMessengeModels(contact)
      
      if let messengeIndex {
        var updatedMessenge = listMessenge[messengeIndex]
        updatedMessenge.messageStatus = .sent
        await interactor.updateMessenge(contact, updatedMessenge)
      }
      return .success(messageID)
    }
    return .failure(URLError(.unknown))
  }
  
  func checkAccessDemo() async {
    guard await interactor.getAppSettingsModel().accessType == .demo else {
      return
    }
    
    await MainActor.run { [weak self] in
      guard let self else { return }
      rightBarLockButton?.isEnabled = false
      rightBarWriteButton?.isEnabled = false
    }
  }
}

// MARK: - Constants

private enum Constants {}
