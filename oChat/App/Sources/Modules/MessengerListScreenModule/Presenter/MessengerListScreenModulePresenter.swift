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
  
  // MARK: - Private properties
  
  private let interactor: MessengerListScreenModuleInteractorInput
  private let factory: MessengerListScreenModuleFactoryInput
  private let incomingDataManager: IIncomingDataManager
  private var centerBarButtonView: SKBarButtonView?
  private var rightBarLockButton: SKBarButtonItem?
  private var rightBarWriteButton: SKBarButtonItem?
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
  
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
    
    setupSKBarButtonView()
    initialSetup()
    incomingDataManagerSetup()
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
    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
      Task { [weak self] in
        guard let self else { return }
        let contactModels = await interactor.getContactModels()
        var updatedContactModel = contactModels[index]
        updatedContactModel.messenges = [
          .init(
            messageType: .systemSuccess,
            messageStatus: .sent,
            message: OChatStrings.MessengerListScreenModuleLocalization
              .Message.SuccessfullyClearedAllChat.title,
            replyMessageText: nil,
            images: [],
            videos: [],
            recording: nil
          )
        ]
        
        await interactor.saveContactModel(updatedContactModel)
        moduleOutput?.dataModelHasBeenUpdated()
        await updateListContacts()
      }
    }
  }
  
  func requestNotification() {
    Task { [weak self] in
      guard let self else { return }
      stateIsNotificationsEnabled = await interactor.requestNotification()
    }
  }
}

// MARK: - MessengerListScreenModuleModuleInput

extension MessengerListScreenModulePresenter: MessengerListScreenModuleModuleInput {
  func getAppSettingsModel() async -> SKAbstractions.AppSettingsModel {
    await interactor.getAppSettingsModel()
  }
  
  func removeContact(index: Int) async {
    stateWidgetModels.remove(at: index)
    let contactModels = await interactor.getContactModels()
    let contactModel = contactModels[index]
    await removeContactModels(contactModel)
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
            var updatedContactModel = contactModel
            var updatedMessenges = updatedContactModel.messenges
            let messageId = UInt32(messageId)
            
            if let messengesIndex = updatedMessenges.firstIndex(where: { $0.tempMessageID == messageId }) {
              updatedMessenges[messengesIndex].messageStatus = .failed
              updatedMessenges[messengesIndex].tempMessageID = nil
              
              updatedContactModel.messenges = updatedMessenges
              
              await interactor.saveContactModel(updatedContactModel)
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
    let updatedContact = factory.removeMessageToContact(id: id, contactModel: contact)
    await interactor.saveContactModel(updatedContact)
    moduleOutput?.dataModelHasBeenUpdated()
    await updateListContacts()
  }
  
  func removeContactModels(_ contactModel: ContactModel) async {
    await interactor.removeContactModels(contactModel)
    await updateListContacts()
  }
  
  @MainActor
  func updateListContacts() async {
    updateIsNotificationsEnabled()
    let contactModels = await interactor.getContactModels()
    updateRedDotToTabBar(contactModels: contactModels)
    
    stateWidgetModels = factory.createDialogWidgetModels(
      messengerDialogModels: contactModels
    )
  }
}

// MARK: - MessengerListScreenModuleInteractorOutput

extension MessengerListScreenModulePresenter: MessengerListScreenModuleInteractorOutput {}

// MARK: - MessengerListScreenModuleFactoryOutput

extension MessengerListScreenModulePresenter: MessengerListScreenModuleFactoryOutput {
  func openMessengerDialogScreen(dialogModel: ContactModel) {
    moduleOutput?.openMessengerDialogScreen(dialogModel: dialogModel)
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
          action: { [weak self] in
            // TODO: - Проверить включен ли пароль на приложение, если включен то заблокировать экран иначе предложить установить код
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
  func updateIsNotificationsEnabled() {
    Task {
      stateIsNotificationsEnabled = await interactor.isNotificationsEnabled()
    }
  }
  
  func incomingDataManagerSetup() {
    incomingDataManager.onAppDidBecomeActive = { [weak self] in
      self?.handleAppDidBecomeActive()
    }
    
    incomingDataManager.onMyOnlineStatusUpdate = { [weak self] status in
      self?.handleMyOnlineStatusUpdate(status)
    }
    
    incomingDataManager.onMessageReceived = { [weak self] messageModel, toxFriendId in
      self?.handleMessageReceived(messageModel, toxFriendId)
    }
    
    incomingDataManager.onRequestChat = { [weak self] messageModel, toxPublicKey in
      self?.handleRequestChat(messageModel, toxPublicKey)
    }
    
    incomingDataManager.onFriendOnlineStatusUpdate = { [weak self] toxPublicKey, status in
      self?.handleFriendOnlineStatusUpdate(toxPublicKey, status)
    }
    
    incomingDataManager.onIsTypingFriendUpdate = { [weak self] toxPublicKey, isTyping in
      self?.handleIsTypingFriendUpdate(toxPublicKey, isTyping)
    }
    
    incomingDataManager.onFriendReadReceipt = { [weak self] toxPublicKey, messageId in
      self?.handleFriendReadReceipt(toxPublicKey, messageId)
    }
    
    incomingDataManager.onFileReceive = { [weak self] publicToxKey, filePath, progress in
      self?.handleFileReceive(publicToxKey, filePath, progress)
    }
    
    incomingDataManager.onFileSender = { [weak self] toxPublicKey, progress, messageID in
      self?.handleFileSender(toxPublicKey, progress, messageID)
    }
    
    incomingDataManager.onFileErrorSender = { [weak self] toxPublicKey, messageID in
      self?.handleFileErrorSender(toxPublicKey, messageID)
    }
    
    incomingDataManager.onScreenshotTaken = { [weak self] in
      self?.handleScreenshotTaken()
    }
  }
  
  func initialSetup() {
    // Отключаем таймер простоя
    UIApplication.shared.isIdleTimerDisabled = true
    
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
      await interactor.stratTOXService()
      let contactModels = await interactor.getContactModels()
      stateWidgetModels = factory.createDialogWidgetModels(messengerDialogModels: contactModels)
      
      await interactor.setAllContactsIsOffline()
      await interactor.setAllContactsNoTyping()
      let token = await interactor.getPushNotificationToken()
      if token == nil {
        await UIApplication.shared.registerForRemoteNotifications()
      }
      
      await updateListContacts()
      await interactor.passcodeNotSetInSystemIOSheck()
      moduleOutput?.dataModelHasBeenUpdated()
    }
    
    updateIsNotificationsEnabled()
  }
  
  func updateContactStatus(
    contact: ContactModel,
    status: MessengeModel.MessageStatus,
    messageId: UInt32?
  ) async {
    guard var updatedLastMessage = contact.messenges.last else { return }
    updatedLastMessage.messageStatus = status
    
    var updatedContact = contact
    updatedContact.status = .online
    updatedContact.messenges[updatedContact.messenges.count - 1] = updatedLastMessage
    
    if let messageId {
      updatedContact.messenges[updatedContact.messenges.count - 1].tempMessageID = messageId
    }
    await interactor.saveContactModel(updatedContact)
  }
  
  func updateRedDotToTabBar(contactModels: [ContactModel]) {
    let newMessages = contactModels.filter({ $0.isNewMessagesAvailable })
    let redDotToTabBarText: String? = newMessages.isEmpty ? nil : "\(newMessages.count)"
    interactor.setRedDotToTabBar(value: redDotToTabBarText)
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
      let messengerModel = await interactor.getMessengerModel()
      
      await MainActor.run { [weak self] in
        guard let self else { return }
        centerBarButtonView?.iconLeftView.image = messengerModel.appSettingsModel.myStatus.imageStatus
        centerBarButtonView?.labelView.text = messengerModel.appSettingsModel.myStatus.title
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
    
    if let messengeModel = contact.messenges.last, messengeModel.messageStatus == .sending {
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
    let messengeIndex = contact.messenges.firstIndex(where: {
      $0.id == contact.messenges.last?.id
    })
    
    if let messengeIndex,
       !contact.messenges[messengeIndex].videos.isEmpty ||
        !contact.messenges[messengeIndex].images.isEmpty ||
        contact.messenges[messengeIndex].recording != nil {
      var files: [URL?] = []
      
      contact.messenges[messengeIndex].videos.forEach { files.append($0.full) }
      contact.messenges[messengeIndex].images.forEach { files.append($0.full) }
      
      await interactor.sendFile(
        toxPublicKey: toxPublicKey,
        recipientPublicKey: encryptionPublicKey,
        recordModel: contact.messenges[messengeIndex].recording,
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
      var updatedContact = contact
      if let messengeIndex {
        var updatedMessenge = updatedContact.messenges[messengeIndex]
        updatedMessenge.messageStatus = .sent
        updatedContact.messenges[messengeIndex] = updatedMessenge
      }
      
      await interactor.saveContactModel(updatedContact)
      return .success(messageID)
    }
    return .failure(URLError(.unknown))
  }
  
  func sendLocalNotificationIfNeeded(contactModel: ContactModel) {
    // Проверка, находится ли приложение в фоне
    DispatchQueue.main.async { [weak self] in
      if UIApplication.shared.applicationState == .background {
        self?.sendLocalNotification(contactModel: contactModel)
      }
    }
  }
  
  func sendLocalNotification(contactModel: ContactModel) {
    let address: String = "\(contactModel.toxAddress?.formatString(minTextLength: 10) ?? "unknown")"
    let content = UNMutableNotificationContent()
    content.title = OChatStrings.MessengerListScreenModuleLocalization
      .LocalNotification.title
    content.body = "\(OChatStrings.MessengerListScreenModuleLocalization.LocalNotification.body) \(address)."
    content.sound = UNNotificationSound.default
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { _ in }
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

// MARK: - Handle IncomingDataManager

private extension MessengerListScreenModulePresenter {
  func handleAppDidBecomeActive() {
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
      guard let self else { return }
      
      Task { [weak self] in
        guard let self else { return }
        if let deepLinkAdress = await interactor.getDeepLinkAdress() {
          moduleOutput?.openNewMessengeScreen(contactAdress: deepLinkAdress)
          interactor.deleteDeepLinkURL()
        }
      }
    }
    
    Task { [weak self] in
      guard let self else { return }
      await interactor.setSelfStatus(isOnline: true)
      await interactor.clearAllMessengeTempID()
      await interactor.passcodeNotSetInSystemIOSheck()
      
      if await interactor.getPushNotificationToken() == nil {
        await UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }
  
  func handleMyOnlineStatusUpdate(_ status: AppSettingsModel.Status) {
    Task { @MainActor [weak self] in
      guard let self else { return }
      centerBarButtonView?.iconLeftView.image = status.imageStatus
      centerBarButtonView?.labelView.text = status.title
    }
  }
  
  func handleMessageReceived(_ messageModel: MessengerNetworkRequestModel, _ toxFriendId: Int32) {
    Task { [weak self] in
      guard let self else { return }
      
      let contactModels = await interactor.getContactModels()
      updateRedDotToTabBar(contactModels: contactModels)
      let messageText = await interactor.decrypt(messageModel.messageText) ?? ""
      let pushNotificationToken = await interactor.decrypt(messageModel.senderPushNotificationToken)
      
      if let contact = factory.searchContact(
        contactModels: contactModels,
        torAddress: messageModel.senderAddress
      ) {
        let updatedContact = factory.updateExistingContact(
          contact: contact,
          messageModel: messageModel,
          messageText: messageText,
          pushNotificationToken: pushNotificationToken,
          images: [],
          videos: [],
          recording: nil
        )
        
        await interactor.saveContactModel(updatedContact)
        await updateListContacts()
        moduleOutput?.dataModelHasBeenUpdated()
        await impactFeedback.impactOccurred()
        sendLocalNotificationIfNeeded(contactModel: updatedContact)
      } else {
        let newContact = factory.createNewContact(
          messageModel: messageModel,
          pushNotificationToken: pushNotificationToken,
          status: .online
        )
        await interactor.saveContactModel(newContact)
        await updateListContacts()
        moduleOutput?.dataModelHasBeenUpdated()
        await impactFeedback.impactOccurred()
        sendLocalNotificationIfNeeded(contactModel: newContact)
      }
    }
  }
  
  func handleRequestChat(_ messageModel: MessengerNetworkRequestModel, _ toxPublicKey: String) {
    Task { [weak self] in
      guard let self else { return }
      
      let contactModels = await interactor.getContactModels()
      guard !contactModels.contains(where: {
        $0.toxAddress == messageModel.senderAddress
      }) else {
        return
      }
      
      let pushNotificationToken = await interactor.decrypt(messageModel.senderPushNotificationToken)
      updateRedDotToTabBar(contactModels: contactModels)
      
      let newContact = factory.createNewContact(
        messageModel: messageModel,
        pushNotificationToken: pushNotificationToken,
        status: .requestChat
      )
      await interactor.saveContactModel(newContact)
      await updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
      await impactFeedback.impactOccurred()
    }
  }
  
  func handleFriendOnlineStatusUpdate(_ toxPublicKey: String, _ status: ContactModel.Status) {
    Task { [weak self] in
      guard let self else { return }
      let contactModel = await interactor.getContactModelsFrom(toxPublicKey: toxPublicKey)
      guard let contactModel else { return }
      
      var updatedContactModel = contactModel
      if status == .offline {
        updatedContactModel.isTyping = false
      }
      
      await interactor.saveContactModel(updatedContactModel)
      await interactor.setStatus(updatedContactModel, status)
      await updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
    }
  }
  
  func handleIsTypingFriendUpdate(_ toxPublicKey: String, _ isTyping: Bool) {
    Task { [weak self] in
      guard let self else { return }
      
      let contactModel = await interactor.getContactModelsFrom(toxPublicKey: toxPublicKey)
      guard let contactModel else { return }
      var updatedContactModel = contactModel
      updatedContactModel.isTyping = isTyping
      updatedContactModel.status = .online
      await interactor.saveContactModel(updatedContactModel)
      await updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
    }
  }
  
  func handleFriendReadReceipt(_ toxPublicKey: String, _ messageId: UInt32) {
    Task { [weak self] in
      guard let self else { return }
      
      let contactModel = await interactor.getContactModelsFrom(toxPublicKey: toxPublicKey)
      guard let contactModel else { return }
      var updatedContactModel = contactModel
      var updatedMessenges = updatedContactModel.messenges
      updatedContactModel.status = .online
      
      if let messengesIndex = updatedMessenges.firstIndex(where: { $0.tempMessageID == messageId }) {
        updatedMessenges[messengesIndex].messageStatus = .sent
        updatedMessenges[messengesIndex].tempMessageID = nil
      }
      updatedContactModel.messenges = updatedMessenges
      
      await interactor.saveContactModel(updatedContactModel)
      await updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
    }
  }
  
  func handleFileReceive(_ publicToxKey: String, _ filePath: URL, _ progress: Double) {
    Task { [weak self] in
      guard let self else { return }
      
      moduleOutput?.handleFileReceive(progress: Int(progress), publicToxKey: publicToxKey)
      if progress < 100 { return }
      
      let contactModels = await interactor.getContactModels()
      
      let passwordEncodedString = interactor.getFileNameWithoutExtension(from: filePath)
      guard let decodedPasswordEncrypt = passwordEncodedString.removingPercentEncoding else {
        return
      }
      
      let password = await interactor.decrypt(decodedPasswordEncrypt)
      guard let password, let receiveAndUnzipFile = try? await interactor.receiveAndUnzipFile(
        zipFileURL: filePath,
        password: password
      ) else {
        return
      }
      let (messageModel, recordingDTO, files) = receiveAndUnzipFile
      
      updateRedDotToTabBar(contactModels: contactModels)
      let messageText = await interactor.decrypt(messageModel.messageText) ?? ""
      let pushNotificationToken = await interactor.decrypt(messageModel.senderPushNotificationToken)
      var images: [MessengeImageModel] = []
      var videos: [MessengeVideoModel] = []
      
      for fileTempURL in files {
        if fileTempURL.isImageFile() {
          let imageFile = interactor.readObjectWith(fileURL: fileTempURL) ?? Data()
          let fileExtension = fileTempURL.pathExtension
          let thumbnailData = interactor.resizeThumbnailImageWithFrame(data: imageFile) ?? Data()
          let thumbnailURL = interactor.saveObjectWith(
            fileName: UUID().uuidString,
            fileExtension: fileExtension,
            data: thumbnailData
          )
          
          guard let thumbnailURL,
                let fullImage = interactor.saveObjectWith(tempURL: fileTempURL),
                let thumbnailName = interactor.getFileName(from: thumbnailURL),
                let fullImageName = interactor.getFileName(from: fullImage) else {
            continue
          }
          
          images.append(
            .init(
              id: UUID().uuidString,
              thumbnailName: thumbnailName,
              fullName: fullImageName
            )
          )
          continue
        }
        
        if fileTempURL.isVideoFile() {
          guard let videoFileURL = interactor.saveObjectWith(tempURL: fileTempURL),
                let videoFileName = interactor.getFileName(from: videoFileURL),
                let firstFrameData = interactor.getFirstFrame(from: videoFileURL),
                let thumbnailResizeData = interactor.resizeThumbnailImageWithFrame(data: firstFrameData),
                let thumbnailURL = interactor.saveObjectWith(
                  fileName: UUID().uuidString,
                  fileExtension: "jpg",
                  data: thumbnailResizeData
                ),
                let thumbnailName = interactor.getFileName(from: thumbnailURL) else {
            continue
          }
          
          videos.append(
            .init(
              id: UUID().uuidString,
              thumbnailName: thumbnailName,
              fullName: videoFileName
            )
          )
          continue
        }
      }
      
      var recordingModel: MessengeRecordingModel?
      
      if let recordingDTO,
         let recordingURL = interactor.saveObjectWith(
          fileName: UUID().uuidString,
          fileExtension: "aac",
          data: recordingDTO.data
         ),
         let recordingName = interactor.getFileName(from: recordingURL) {
        recordingModel = .init(
          duration: recordingDTO.duration,
          waveformSamples: recordingDTO.waveformSamples,
          name: recordingName
        )
      }
      
      if let contact = factory.searchContact(
        contactModels: contactModels,
        torAddress: messageModel.senderAddress
      ) {
        let updatedContact = factory.updateExistingContact(
          contact: contact,
          messageModel: messageModel,
          messageText: messageText,
          pushNotificationToken: pushNotificationToken,
          images: images,
          videos: videos,
          recording: recordingModel
        )
        
        await interactor.saveContactModel(updatedContact)
        await updateListContacts()
        moduleOutput?.dataModelHasBeenUpdated()
        interactor.clearTemporaryDirectory()
        await impactFeedback.impactOccurred()
        sendLocalNotificationIfNeeded(contactModel: updatedContact)
      } else {
        let newContact = factory.createNewContact(
          messageModel: messageModel,
          pushNotificationToken: pushNotificationToken,
          status: .online
        )
        await interactor.saveContactModel(newContact)
        await updateListContacts()
        moduleOutput?.dataModelHasBeenUpdated()
        interactor.clearTemporaryDirectory()
        await impactFeedback.impactOccurred()
        sendLocalNotificationIfNeeded(contactModel: newContact)
      }
    }
  }
  
  func handleFileSender(_ toxPublicKey: String, _ progress: Double, _ messageID: String) {
    Task { [weak self] in
      guard let self else { return }
      
      moduleOutput?.handleFileSender(progress: Int(progress), publicToxKey: toxPublicKey)
      if progress < 100 { return }
      
      let contactModel = await interactor.getContactModelsFrom(toxPublicKey: toxPublicKey)
      guard let contactModel else { return }
      var updatedContactModel = contactModel
      var updatedMessenges = updatedContactModel.messenges
      updatedContactModel.status = .online
      
      if let messengesIndex = updatedMessenges.firstIndex(where: { $0.id == messageID }) {
        updatedMessenges[messengesIndex].messageStatus = .sent
      }
      updatedContactModel.messenges = updatedMessenges
      
      await interactor.saveContactModel(updatedContactModel)
      await updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
    }
  }
  
  func handleFileErrorSender(_ toxPublicKey: String, _ messageID: String) {
    Task { [weak self] in
      guard let self else { return }
      let contactModel = await interactor.getContactModelsFrom(toxPublicKey: toxPublicKey)
      guard let contactModel else { return }
      var updatedContactModel = contactModel
      var updatedMessenges = updatedContactModel.messenges
      updatedContactModel.status = .online
      
      if let messengesIndex = updatedMessenges.firstIndex(where: { $0.id == messageID }) {
        updatedMessenges[messengesIndex].messageStatus = .failed
      }
      updatedContactModel.messenges = updatedMessenges
      
      await interactor.saveContactModel(updatedContactModel)
      await updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
    }
  }
  
  func handleScreenshotTaken() {
    interactor.showNotification(
      .negative(
        title: OChatStrings.MessengerListScreenModuleLocalization
          .BanScreenshot.description
      )
    )
  }
}

// MARK: - Constants

private enum Constants {}
