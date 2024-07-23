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
import UniformTypeIdentifiers
import UIKit

final class MessengerListScreenModulePresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateWidgetModels: [WidgetCryptoView.Model] = []
  @Published var stateIsNotificationsEnabled = true
  
  // MARK: - Internal properties
  
  weak var moduleOutput: MessengerListScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: MessengerListScreenModuleInteractorInput
  private let factory: MessengerListScreenModuleFactoryInput
  private var barButtonView: SKBarButtonView?
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(
    interactor: MessengerListScreenModuleInteractorInput,
    factory: MessengerListScreenModuleFactoryInput
  ) {
    self.interactor = interactor
    self.factory = factory
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    
    setupSKBarButtonView()
    initialSetup()
  }
  
  // MARK: - Internal func
  
  func clearContact(index: Int) {
    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
      guard let self else { return }
      DispatchQueue.global().async { [weak self] in
        guard let self else { return }
        interactor.getContactModels { [weak self] contactModels in
          guard let self else { return }
          var updatedContactModel = contactModels[index]
          updatedContactModel.messenges = [
            .init(
              messageType: .systemSuccess,
              messageStatus: .sent,
              message: "Вы успешно очистили всю историю переписки",
              replyMessageText: nil,
              images: [],
              videos: [],
              recording: nil
            )
          ]
          interactor.saveContactModel(updatedContactModel) { [weak self] in
            guard let self else { return }
            moduleOutput?.dataModelHasBeenUpdated()
            updateListContacts()
          }
        }
      }
    }
  }
  
  func removeContact(index: Int) {
    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
      guard let self else { return }
      stateWidgetModels.remove(at: index)
      DispatchQueue.global().async { [weak self] in
        guard let self else { return }
        interactor.getContactModels { [weak self] contactModels in
          guard let self else { return }
          let contactModel = contactModels[index]
          removeContactModels(contactModel, completion: { [weak self] in
            guard let self else { return }
            moduleOutput?.dataModelHasBeenUpdated()
            updateListContacts()
          })
        }
      }
    }
  }
  
  func requestNotification() {
    interactor.requestNotification { [weak self] granted in
      self?.stateIsNotificationsEnabled = granted
    }
  }
}

// MARK: - MessengerListScreenModuleModuleInput

extension MessengerListScreenModulePresenter: MessengerListScreenModuleModuleInput {
  func sendPushNotification(contact: ContactModel) {
    interactor.sendPushNotification(contact: contact)
  }
  
  func setUserIsTyping(
    _ isTyping: Bool,
    to toxPublicKey: String,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    interactor.setUserIsTyping(isTyping, to: toxPublicKey, completion: completion)
  }
  
  func saveContactModel(_ model: SKAbstractions.ContactModel) {
    interactor.saveContactModel(model) { [weak self] in
      guard let self else { return }
      updateListContacts()
    }
  }
  
  func sendInitiateChat(contactModel: ContactModel) {
    checkingContactPublicKey(contact: contactModel) { [weak self] updatedContactModel in
      guard let self else { return }
      sendInitiateChatNetworkRequest(contact: updatedContactModel) { [weak self] _ in
        guard let self else { return }
        moduleOutput?.dataModelHasBeenUpdated()
        updateListContacts()
      }
    }
  }
  
  func confirmRequestForDialog(contactModel: ContactModel) {
    guard let toxPublicKey = contactModel.toxPublicKey else {
      interactor.showNotification(.negative(title: "Нет публичного ключа: toxPublicKey"))
      return
    }
    
    interactor.confirmFriendRequest(with: toxPublicKey) { [weak self] result in
      guard let self else { return }
      switch result {
      case let .success(toxPublicKey):
        var updatedContactModel = contactModel
        updatedContactModel.status = .online
        interactor.saveContactModel(updatedContactModel) { [weak self] in
          guard let self else { return }
          moduleOutput?.dataModelHasBeenUpdated()
          updateListContacts()
        }
      case .failure:
        interactor.showNotification(.negative(title: "Ошибка добавления контакта"))
        interactor.removeContactModels(contactModel) { [weak self] in
          guard let self else { return }
          moduleOutput?.dataModelHasBeenUpdated()
          updateListContacts()
        }
      }
    }
  }
  
  func cancelRequestForDialog(contactModel: ContactModel) {
    removeContactModels(contactModel) { [weak self] in
      guard let self else { return }
      interactor.showNotification(.positive(title: "Контакт был удален"))
    }
  }
  
  func sendMessage(contact: ContactModel, completion: (() -> Void)?) {
    guard contact.status == .online else {
      interactor.showNotification(.negative(title: "Контакт не в сети"))
      return
    }
    
    checkingContactPublicKey(contact: contact) { [weak self] updatedContactModel in
      guard let self else { return }
      sendMessageNetworkRequest(contact: updatedContactModel) { [weak self] result in
        guard let self else { return }
        switch result {
        case let .success(messageId):
          updateContactStatus(
            contact: contact,
            status: .sending,
            messageId: UInt32(messageId)
          ) { [weak self] in
            guard let self else { return }
            moduleOutput?.dataModelHasBeenUpdated()
            updateListContacts()
            completion?()
          }
          
          Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            guard let self else { return }
            interactor.getContactModelsFrom(toxAddress: contact.toxAddress ?? "") { [weak self] contactModel in
              guard let self, let contactModel else { return }
              var updatedContactModel = contactModel
              var updatedMessenges = updatedContactModel.messenges
              let messageId = UInt32(messageId)
              
              if let messengesIndex = updatedMessenges.firstIndex(where: { $0.tempMessageID == messageId }) {
                updatedMessenges[messengesIndex].messageStatus = .failed
                updatedMessenges[messengesIndex].tempMessageID = nil
                
                updatedContactModel.messenges = updatedMessenges
                
                interactor.saveContactModel(updatedContactModel) { [weak self] in
                  guard let self else { return }
                  updateListContacts()
                  moduleOutput?.dataModelHasBeenUpdated()
                }
              }
            }
          }
        case let .failure(error):
          updateContactStatus(contact: contact, status: .failed, messageId: nil) { [weak self] in
            guard let self else { return }
            moduleOutput?.dataModelHasBeenUpdated()
            updateListContacts()
            completion?()
          }
        }
      }
    }
  }
  
  func getContactModelsFrom(toxAddress: String, completion: ((ContactModel?) -> Void)?) {
    interactor.getContactModelsFrom(toxAddress: toxAddress, completion: completion)
  }
  
  func removeMessage(id: String, contact: ContactModel) {
    var updatedContact = factory.removeMessageToContact(id: id, contactModel: contact)
    interactor.saveContactModel(updatedContact) { [weak self] in
      guard let self else { return }
      
      moduleOutput?.dataModelHasBeenUpdated()
      updateListContacts()
    }
  }
  
  func removeContactModels(_ contactModel: ContactModel, completion: (() -> Void)?) {
    interactor.removeContactModels(contactModel) { [weak self]in
      guard let self else { return }
      updateListContacts(completion: completion)
    }
  }
  
  func updateListContacts(completion: (() -> Void)? = nil) {
    updateIsNotificationsEnabled()
    interactor.getContactModels { [weak self] contactModels in
      guard let self else {
        return
      }
      
      updateRedDotToTabBar(contactModels: contactModels)
      
      stateWidgetModels = factory.createDialogWidgetModels(
        messengerDialogModels: contactModels
      )
      completion?()
    }
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
  
  var rightBarButtonItem: SKBarButtonItem? {
    .init(.write(action: { [weak self] in
      self?.moduleOutput?.openNewMessengeScreen(contactAdress: nil)
    }))
  }
  
  var centerBarButtonItem: SKBarButtonViewType? {
    .widgetCryptoView(barButtonView)
  }
}

// MARK: - Private

private extension MessengerListScreenModulePresenter {
  func updateIsNotificationsEnabled() {
    interactor.isNotificationsEnabled { [weak self] enabled in
      self?.stateIsNotificationsEnabled = enabled
    }
  }
  
  func initialSetup() {
    // Отключаем таймер простоя
    UIApplication.shared.isIdleTimerDisabled = true
    
    interactor.clearAllMessengeTempID(completion: {})
    interactor.startPeriodicFriendStatusCheck { [weak self] in
      guard let self else { return }
      updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
    }
    
    updateIsNotificationsEnabled()
    
    interactor.setSelfStatus(isOnline: true)
    interactor.getContactModels { [weak self] contactModels in
      guard let self else {
        return
      }
      
      stateWidgetModels = factory.createDialogWidgetModels(messengerDialogModels: contactModels)
    }
    interactor.stratTORxService()
    interactor.passcodeNotSetInSystemIOSheck()
    
    interactor.setAllContactsIsOffline { [weak self] in
      guard let self else { return }
      interactor.setAllContactsNoTyping { [weak self] in
        guard let self else { return }
        
        updateListContacts()
        moduleOutput?.dataModelHasBeenUpdated()
      }
    }
    
    interactor.getPushNotificationToken { [weak self] token in
      guard token == nil else {
        return
      }
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleMyOnlineStatus(_:)),
      name: Notification.Name(NotificationConstants.didUpdateMyOnlineStatus.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleMessage(_:)),
      name: Notification.Name(NotificationConstants.didReceiveMessage.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleRequestChat(_:)),
      name: Notification.Name(NotificationConstants.didInitiateChat.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleFriendOnlineStatus(_:)),
      name: Notification.Name(NotificationConstants.didUpdateFriendOnlineStatus.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(userDidScreenshot),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleIsTypingFriend(_:)),
      name: Notification.Name(NotificationConstants.isTyping.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleFriendReadReceipt(_:)),
      name: Notification.Name(NotificationConstants.didUpdateFriendReadReceipt.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleFileReceive(_:)),
      name: Notification.Name(NotificationConstants.didUpdateFileReceive.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleFileSender(_:)),
      name: Notification.Name(NotificationConstants.didUpdateFileSend.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleFileErrorSender(_:)),
      name: Notification.Name(NotificationConstants.didUpdateFileErrorSend.rawValue),
      object: nil
    )
  }
  
  func updateContactStatus(
    contact: ContactModel,
    status: MessengeModel.MessageStatus,
    messageId: UInt32?,
    completion: @escaping () -> Void
  ) {
    guard var updatedLastMessage = contact.messenges.last else { return }
    updatedLastMessage.messageStatus = status
    
    var updatedContact = contact
    updatedContact.status = .online
    updatedContact.messenges[updatedContact.messenges.count - 1] = updatedLastMessage
    
    if let messageId {
      updatedContact.messenges[updatedContact.messenges.count - 1].tempMessageID = messageId
    }
    
    interactor.saveContactModel(updatedContact) { [weak self] in
      guard let self else { return }
      completion()
    }
  }
  
  func updateRedDotToTabBar(contactModels: [ContactModel]) {
    let newMessages = contactModels.filter({ $0.isNewMessagesAvailable })
    let redDotToTabBarText: String? = newMessages.isEmpty ? nil : "\(newMessages.count)"
    interactor.setRedDotToTabBar(value: redDotToTabBarText)
  }
  
  func setupSKBarButtonView() {
    barButtonView = SKBarButtonView(
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
    
    interactor.getMessengerModel { [ weak self] messengerModel in
      guard let self else {
        return
      }
      
      barButtonView?.iconLeftView.image = messengerModel.myStatus.imageStatus
      barButtonView?.labelView.text = messengerModel.myStatus.title
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
    senderPushNotificationToken: String?,
    completion: ((_ recipientTorAddress: String,
                  _ requestModel: MessengerNetworkRequestModel) -> Void)?
  ) {
    guard let senderAddress else {
      interactor.showNotification(.negative(title: "Нет адреса получателя!"))
      return
    }
    
    let requestModel = MessengerNetworkRequestModel(
      messageText: message,
      messageID: messageID,
      replyMessageText: replyMessageText,
      senderAddress: senderAddress,
      senderLocalMeshAddress: senderLocalMeshAddress ?? "",
      senderPublicKey: senderPublicKey,
      senderToxPublicKey: senderToxPublicKey, 
      senderPushNotificationToken: senderPushNotificationToken
    )
    completion?(senderAddress, requestModel)
  }
  
  func checkingContactPublicKey(contact: ContactModel, completion: ((ContactModel) -> Void)?) {
    guard let toxAddress = contact.toxAddress else {
      interactor.showNotification(.negative(title: "Неправильный адрес контакта"))
      return
    }
    
    var updatedContactModel = contact
    if contact.toxPublicKey == nil {
      let toxPublicKey = interactor.getToxPublicKey(from: toxAddress)
      updatedContactModel.toxPublicKey = toxPublicKey
    }
    completion?(updatedContactModel)
  }
  
  func prepareAndEncryptDataForNetworkRequest(
    contact: ContactModel,
    completion: ((_ recipientTorAddress: String,
                  _ requestModel: MessengerNetworkRequestModel) -> Void)?
  ) {
    guard let senderPublicKey = interactor.publicKey(from: interactor.getDeviceIdentifier()) else {
      interactor.showNotification(.negative(title: "Не получилось создать Публичный ключ для шифрования"))
      return
    }
    
    var message = ""
    var messageID = ""
    var replyMessageText: String?
    
    if let messengeModel = contact.messenges.last, messengeModel.messageStatus == .sending {
      message = messengeModel.message
      messageID = messengeModel.id
      replyMessageText = messengeModel.replyMessageText
    }
    
    interactor.getPushNotificationToken { [weak self] pushNotificationToken in
      guard let self else { return }
      interactor.saveContactModel(
        contact,
        completion: { [weak self] in
          guard let self else { return }
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
          
          interactor.getToxAddress { [weak self] result in
            guard let self, let toxAddress = try? result.get() else { return }
            interactor.getToxPublicKey { [weak self] toxPublicKey in
              guard let self, let toxPublicKey else { return }
              createRequestModel(
                message: messageForSend, 
                messageID: messageID,
                replyMessageText: replyMessageText,
                senderAddress: toxAddress,
                senderLocalMeshAddress: nil,
                senderPublicKey: senderPublicKey,
                senderToxPublicKey: toxPublicKey,
                senderPushNotificationToken: senderPushNotificationTokenForSend,
                completion: completion
              )
            }
          }
        }
      )
    }
  }
  
  func sendInitiateChatNetworkRequest(
    contact: ContactModel,
    completion: ((Result<Void, Error>) -> Void)?
  ) {
    prepareAndEncryptDataForNetworkRequest(
      contact: contact
    ) { [weak self] senderAddress, requestModel in
      guard let self, let toxAddress = contact.toxAddress else { return }
      interactor.initialChat(
        senderAddress: toxAddress,
        messengerRequest: requestModel) { [weak self] result in
          guard let self else { return }
          switch result {
          case .success:
            completion?(.success(()))
          case let .failure(error):
            completion?(.failure(error))
          }
        }
    }
  }
  
  func sendMessageNetworkRequest(
    contact: ContactModel,
    completion: ((Result<Int32, Error>) -> Void)?
  ) {
    guard let toxPublicKey = contact.toxPublicKey else {
      return
    }
    prepareAndEncryptDataForNetworkRequest(
      contact: contact
    ) {
      [weak self] recipientTorAddress, requestModel in
      guard let self, let encryptionPublicKey = contact.encryptionPublicKey else { return }
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
        
        interactor.sendFile(
          toxPublicKey: toxPublicKey, 
          recipientPublicKey: encryptionPublicKey,
          recordModel: contact.messenges[messengeIndex].recording,
          messengerRequest: requestModel,
          files: files.compactMap({ $0 })
        )
        
        return
      }
      
      if let messageText = requestModel.messageText, messageText.count > 300 {
        interactor.sendFile(
          toxPublicKey: toxPublicKey,
          recipientPublicKey: encryptionPublicKey,
          recordModel: nil,
          messengerRequest: requestModel,
          files: []
        )
        return
      }
      
      interactor.sendMessage(
        toxPublicKey: toxPublicKey,
        messengerRequest: requestModel
      ) { [weak self] result in
        guard let self else { return }
        switch result {
        case let .success(messageId):
          var updatedContact = contact
          if let messengeIndex {
            var updatedMessenge = updatedContact.messenges[messengeIndex]
            updatedMessenge.messageStatus = .sent
            updatedContact.messenges[messengeIndex] = updatedMessenge
          }
          
          interactor.saveContactModel(updatedContact) {
            completion?(.success((messageId)))
          }
        case let .failure(error):
          completion?(.failure(error))
        }
      }
    }
  }
  
  func sendLocalNotificationIfNeeded(contactModel: ContactModel) {
    // Проверка, находится ли приложение в фоне
    if UIApplication.shared.applicationState == .background {
      sendLocalNotification(contactModel: contactModel)
    }
  }
  
  func sendLocalNotification(contactModel: ContactModel) {
    let address: String = "\(contactModel.toxAddress?.formatString(minTextLength: 10) ?? "unknown")"
    let content = UNMutableNotificationContent()
    content.title = "Новое сообщение"
    content.body = "У вас есть новое сообщение в чате от \(address)."
    content.sound = UNNotificationSound.default
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        print("Error adding notification: \(error)")
      }
    }
  }
}

// MARK: - Handle NotificationCenter

private extension MessengerListScreenModulePresenter {
  @objc
  func appDidBecomeActive() {
    interactor.clearAllMessengeTempID(completion: {})
    interactor.setSelfStatus(isOnline: true)
    interactor.passcodeNotSetInSystemIOSheck()
    
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
      guard let self else { return }
      
      interactor.getDeepLinkAdress { [weak self] contactAdress in
        guard let self, let contactAdress else {
          return
        }
        
        moduleOutput?.openNewMessengeScreen(contactAdress: contactAdress)
        interactor.deleteDeepLinkURL()
      }
    }
    
    interactor.getPushNotificationToken { [weak self] token in
      guard token == nil else {
        return
      }
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }
  
  @objc
  func handleMyOnlineStatus(_ notification: Notification) {
    if let status = notification.userInfo?["onlineStatus"] as? MessengerModel.Status {
      barButtonView?.iconLeftView.image = status.imageStatus
      barButtonView?.labelView.text = status.title
    }
  }
  
  @objc
  func handleFriendOnlineStatus(_ notification: Notification) {
    if let toxPublicKey = notification.userInfo?["publicKey"] as? String,
       let status = notification.userInfo?["status"] as? ContactModel.Status {
      interactor.getContactModelsFrom(toxPublicKey: toxPublicKey) { [weak self] contactModel in
        guard let self, let contactModel else { return }
        
        var updatebleContactModel = contactModel
        if status == .offline {
          updatebleContactModel.isTyping = false
        }
        
        interactor.saveContactModel(updatebleContactModel) { [weak self] in
          guard let self else { return }
          interactor.setStatus(updatebleContactModel, status) { [weak self] in
            guard let self else { return }
            updateListContacts()
            moduleOutput?.dataModelHasBeenUpdated()
          }
        }
      }
    }
  }
  
  @objc
  func handleIsTypingFriend(_ notification: Notification) {
    if let toxPublicKey = notification.userInfo?["publicKey"] as? String,
       let isTyping = notification.userInfo?["isTyping"] as? Bool {
      interactor.getContactModelsFrom(toxPublicKey: toxPublicKey) { [weak self] contactModel in
        guard let self, let contactModel else { return }
        var updatedContactModel = contactModel
        updatedContactModel.isTyping = isTyping
        updatedContactModel.status = .online
        interactor.saveContactModel(updatedContactModel) { [weak self] in
          guard let self else { return }
          updateListContacts()
          moduleOutput?.dataModelHasBeenUpdated()
        }
      }
    }
  }
  
  @objc
  func handleFileErrorSender(_ notification: Notification) {
    if let toxPublicKey = notification.userInfo?["publicKey"] as? String,
       let messageID = notification.userInfo?["messageID"] as? String {
      
      interactor.getContactModelsFrom(toxPublicKey: toxPublicKey) { [weak self] contactModel in
        guard let self, let contactModel else { return }
        var updatedContactModel = contactModel
        var updatedMessenges = updatedContactModel.messenges
        updatedContactModel.status = .online
        
        if let messengesIndex = updatedMessenges.firstIndex(where: { $0.id == messageID }) {
          updatedMessenges[messengesIndex].messageStatus = .failed
        }
        updatedContactModel.messenges = updatedMessenges
        
        interactor.saveContactModel(updatedContactModel) { [weak self] in
          guard let self else { return }
          updateListContacts()
          moduleOutput?.dataModelHasBeenUpdated()
        }
      }
    }
  }
  
  @objc
  func handleFileSender(_ notification: Notification) {
    if let toxPublicKey = notification.userInfo?["publicKey"] as? String,
       let progress = notification.userInfo?["progress"] as? Double,
       let messageID = notification.userInfo?["messageID"] as? String {
      
      moduleOutput?.handleFileSender(progress: Int(progress), publicToxKey: toxPublicKey)
      if progress < 100 { return }
      
      interactor.getContactModelsFrom(toxPublicKey: toxPublicKey) { [weak self] contactModel in
        guard let self, let contactModel else { return }
        var updatedContactModel = contactModel
        var updatedMessenges = updatedContactModel.messenges
        updatedContactModel.status = .online
        
        if let messengesIndex = updatedMessenges.firstIndex(where: { $0.id == messageID }) {
          updatedMessenges[messengesIndex].messageStatus = .sent
        }
        updatedContactModel.messenges = updatedMessenges
        
        interactor.saveContactModel(updatedContactModel) { [weak self] in
          guard let self else { return }
          updateListContacts()
          moduleOutput?.dataModelHasBeenUpdated()
        }
      }
    }
  }
  
  @objc
  func handleFileReceive(_ notification: Notification) {
    if let publicToxKey = notification.userInfo?["publicKey"] as? String,
       let filePath = notification.userInfo?["filePath"] as? URL,
       let progress = notification.userInfo?["progress"] as? Double {
      
      moduleOutput?.handleFileReceive(progress: Int(progress), publicToxKey: publicToxKey)
      if progress < 100 { return }
      
      interactor.getContactModels { [weak self] contactModels in
        guard let self else { return }
        
        let passwordEncodedString = interactor.getFileNameWithoutExtension(from: filePath)
        guard let decodedPasswordEncrypt = passwordEncodedString.removingPercentEncoding else {
          return
        }
        
        interactor.decrypt(decodedPasswordEncrypt) { [weak self] password in
          guard let self, let password else { return }
          interactor.receiveAndUnzipFile(
            zipFileURL: filePath,
            password: password
          ) { [weak self] result in
            guard let self, let result = try? result.get() else {
              return
            }
            let messageModel = result.model
            updateRedDotToTabBar(contactModels: contactModels)
            
            interactor.decrypt(messageModel.messageText) { [weak self] messageText in
              guard let self else { return }
              interactor.decrypt(messageModel.senderPushNotificationToken) { [weak self] pushNotificationToken in
                guard let self else { return }
                var images: [MessengeImageModel] = []
                var videos: [MessengeVideoModel] = []
                
                for fileTempURL in result.files {
                  
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
                
                if let recordingDTO = result.recordingDTO,
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
                  var updatedContact = contact
                  updatedContact = factory.addMessageToContact(
                    message: messageText,
                    contactModel: updatedContact,
                    messageType: .received,
                    replyMessageText: messageModel.replyMessageText,
                    images: images,
                    videos: videos,
                    recording: recordingModel
                  )
                  updatedContact.status = .online
                  if let senderPushNotificationToken = pushNotificationToken {
                    updatedContact.pushNotificationToken = senderPushNotificationToken
                  }
                  updatedContact.toxAddress = messageModel.senderAddress
                  updatedContact.isNewMessagesAvailable = true
                  updatedContact.encryptionPublicKey = messageModel.senderPublicKey
                  interactor.saveContactModel(updatedContact, completion: { [weak self] in
                    guard let self else { return }
                    updateListContacts()
                    moduleOutput?.dataModelHasBeenUpdated()
                    interactor.clearTemporaryDirectory()
                    impactFeedback.impactOccurred()
                    sendLocalNotificationIfNeeded(contactModel: contact)
                  })
                } else {
                  let contact = ContactModel(
                    name: nil,
                    toxAddress: messageModel.senderAddress,
                    meshAddress: messageModel.senderLocalMeshAddress,
                    messenges: [],
                    status: .online,
                    encryptionPublicKey: messageModel.senderPublicKey,
                    toxPublicKey: nil,
                    pushNotificationToken: pushNotificationToken,
                    isNewMessagesAvailable: true,
                    isTyping: false
                  )
                  interactor.saveContactModel(contact, completion: { [weak self] in
                    guard let self else { return }
                    updateListContacts()
                    moduleOutput?.dataModelHasBeenUpdated()
                    interactor.clearTemporaryDirectory()
                    impactFeedback.impactOccurred()
                    sendLocalNotificationIfNeeded(contactModel: contact)
                  })
                }
              }
            }
          }
        }
      }
    }
  }
  
  @objc
  func handleFriendReadReceipt(_ notification: Notification) {
    if let toxPublicKey = notification.userInfo?["publicKey"] as? String,
       let messageId = notification.userInfo?["messageId"] as? UInt32 {
      interactor.getContactModelsFrom(toxPublicKey: toxPublicKey) { [weak self] contactModel in
        guard let self, let contactModel else { return }
        var updatedContactModel = contactModel
        var updatedMessenges = updatedContactModel.messenges
        updatedContactModel.status = .online
        
        if let messengesIndex = updatedMessenges.firstIndex(where: { $0.tempMessageID == messageId }) {
          updatedMessenges[messengesIndex].messageStatus = .sent
          updatedMessenges[messengesIndex].tempMessageID = nil
        }
        updatedContactModel.messenges = updatedMessenges
        
        interactor.saveContactModel(updatedContactModel) { [weak self] in
          guard let self else { return }
          updateListContacts()
          moduleOutput?.dataModelHasBeenUpdated()
        }
      }
    }
  }
  
  @objc
  func handleRequestChat(_ notification: Notification) {
    if let messageModel = notification.userInfo?["requestChat"] as? MessengerNetworkRequestModel,
       let toxPublicKey = notification.userInfo?["toxPublicKey"] as? String {
      interactor.getContactModels { [weak self] contactModels in
        guard let self,
              !contactModels.contains(where: {
                $0.toxAddress == messageModel.senderAddress
              }) else {
          return
        }
        
        interactor.decrypt(messageModel.senderPushNotificationToken) { [weak self] pushNotificationToken in
          guard let self else { return }
          
          updateRedDotToTabBar(contactModels: contactModels)
          
          let newContact = ContactModel(
            name: nil,
            toxAddress: messageModel.senderAddress,
            meshAddress: messageModel.senderLocalMeshAddress,
            messenges: [],
            status: .requestChat,
            encryptionPublicKey: messageModel.senderPublicKey,
            toxPublicKey: toxPublicKey,
            pushNotificationToken: pushNotificationToken,
            isNewMessagesAvailable: true,
            isTyping: false
          )
          interactor.saveContactModel(newContact, completion: { [weak self] in
            guard let self else { return }
            updateListContacts()
            moduleOutput?.dataModelHasBeenUpdated()
            impactFeedback.impactOccurred()
          })
        }
      }
    }
  }
  
  @objc
  func handleMessage(_ notification: Notification) {
    if let messageModel = notification.userInfo?["data"] as? MessengerNetworkRequestModel,
       let toxFriendId = notification.userInfo?["toxFriendId"] as? Int32 {
      interactor.getContactModels { [weak self] contactModels in
        guard let self else { return }
        
        updateRedDotToTabBar(contactModels: contactModels)
        interactor.decrypt(messageModel.messageText) { [weak self] messageText in
          guard let self else { return }
          interactor.decrypt(messageModel.senderPushNotificationToken) { [weak self] pushNotificationToken in
            guard let self else { return }
            
            if let contact = factory.searchContact(
              contactModels: contactModels,
              torAddress: messageModel.senderAddress
            ) {
              var updatedContact = contact
              updatedContact = factory.addMessageToContact(
                message: messageText,
                contactModel: updatedContact,
                messageType: .received,
                replyMessageText: messageModel.replyMessageText,
                images: [],
                videos: [],
                recording: nil
              )

              updatedContact.status = .online
              if let senderPushNotificationToken = pushNotificationToken {
                updatedContact.pushNotificationToken = senderPushNotificationToken
              }
              updatedContact.toxAddress = messageModel.senderAddress
              updatedContact.isNewMessagesAvailable = true
              updatedContact.encryptionPublicKey = messageModel.senderPublicKey
              interactor.saveContactModel(updatedContact, completion: { [weak self] in
                guard let self else { return }
                updateListContacts()
                moduleOutput?.dataModelHasBeenUpdated()
                impactFeedback.impactOccurred()
                sendLocalNotificationIfNeeded(contactModel: updatedContact)
              })
            } else {
              let contact = ContactModel(
                name: nil,
                toxAddress: messageModel.senderAddress,
                meshAddress: messageModel.senderLocalMeshAddress,
                messenges: [],
                status: .online,
                encryptionPublicKey: messageModel.senderPublicKey,
                toxPublicKey: nil,
                pushNotificationToken: pushNotificationToken,
                isNewMessagesAvailable: true,
                isTyping: false
              )
              interactor.saveContactModel(contact, completion: { [weak self] in
                guard let self else { return }
                updateListContacts()
                moduleOutput?.dataModelHasBeenUpdated()
                impactFeedback.impactOccurred()
                sendLocalNotificationIfNeeded(contactModel: contact)
              })
            }
          }
        }
      }
    }
  }
  
  @objc func userDidScreenshot() {
    moduleOutput?.userDidScreenshot()
    impactFeedback.impactOccurred()
  }
}

// MARK: - Constants

private enum Constants {}

// TODO: - Вынести в Foundation
// Расширение для определения типа содержимого файла по URL

extension URL {
  /// Определяет тип содержимого файла по его URL.
  func getFileType() -> UTType? {
    do {
      let resourceValues = try self.resourceValues(forKeys: [.contentTypeKey])
      return resourceValues.contentType
    } catch {
      print("Ошибка при получении типа файла: \(error)")
      return nil
    }
  }
  
  /// Проверяет, является ли файл изображением.
  func isImageFile() -> Bool {
    if let fileType = self.getFileType() {
      return fileType.conforms(to: .image)
    } else {
      return ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "heic"].contains(self.pathExtension.lowercased())
    }
  }
  
  /// Проверяет, является ли файл видео.
  func isVideoFile() -> Bool {
    if let fileType = self.getFileType() {
      return fileType.conforms(to: .movie)
    } else {
      return ["mp4", "mov", "avi", "mkv", "wmv"].contains(self.pathExtension.lowercased())
    }
  }
  
  /// Проверяет, является ли файл аудио.
  func isAudioFile() -> Bool {
    if let fileType = self.getFileType() {
      return fileType.conforms(to: .audio)
    } else {
      return ["mp3", "wav", "aac", "flac"].contains(self.pathExtension.lowercased())
    }
  }
}
