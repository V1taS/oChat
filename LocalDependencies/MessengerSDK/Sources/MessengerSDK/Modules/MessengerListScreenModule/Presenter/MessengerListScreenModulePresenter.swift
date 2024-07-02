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
              message: "Вы успешно очистили всю историю переписки"
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
      moduleOutput?.dataModelHasBeenUpdated()
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
        rightImage: UIImage(systemName: "chevron.down")?
          .withTintColor(SKStyleAsset.ghost.color, renderingMode: .alwaysTemplate),
        isEnabled: true,
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
    if let messengeModel = contact.messenges.last, messengeModel.messageStatus == .sending {
      message = messengeModel.message
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
            let pushNotificationTokenEncrypt = interactor.encrypt(pushNotificationToken, publicKey: encryptionPublicKey)
            senderPushNotificationTokenForSend = pushNotificationTokenEncrypt
          }
          
          interactor.getToxAddress { [weak self] result in
            guard let self, let toxAddress = try? result.get() else { return }
            interactor.getToxPublicKey { [weak self] toxPublicKey in
              guard let self, let toxPublicKey else { return }
              createRequestModel(
                message: messageForSend,
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
    ) { [weak self] recipientTorAddress, requestModel in
      guard let self else { return }
      
      interactor.sendMessage(
        toxPublicKey: toxPublicKey,
        messengerRequest: requestModel
      ) { [weak self] result in
        guard let self else { return }
        switch result {
        case let .success(messageId):
          var updatedContact = contact
          if let messengeIndex = contact.messenges.firstIndex(where: {
            $0.id == updatedContact.messenges.last?.id
          }) {
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
}

// MARK: - Handle NotificationCenter

private extension MessengerListScreenModulePresenter {
  @objc
  func appDidBecomeActive() {
    interactor.clearAllMessengeTempID(completion: {})
    interactor.setSelfStatus(isOnline: true)
    interactor.passcodeNotSetInSystemIOSheck()
    
    interactor.setAllContactsIsOffline { [weak self] in
      guard let self else { return }
      updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
    }
    
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
                messageType: .received
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
              })
            }
          }
        }
      }
    }
  }
  
  @objc func userDidScreenshot() {
    moduleOutput?.userDidScreenshot()
  }
}

// MARK: - Constants

private enum Constants {}
