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
}

// MARK: - MessengerListScreenModuleModuleInput

extension MessengerListScreenModulePresenter: MessengerListScreenModuleModuleInput {
  func saveContactModel(_ model: SKAbstractions.ContactModel) {
    interactor.saveContactModel(model) { [weak self] in
      guard let self else { return }
      moduleOutput?.dataModelHasBeenUpdated()
      updateListContacts()
    }
  }
  
  func sendInitiateChat(contactModel: ContactModel) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      interactor.showNotification(.positive(title: "Запрос отправлен"))
    }
    
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
        interactor.showNotification(.positive(title: "Контакт успешно добавлен"))
      case .failure:
        interactor.showNotification(.negative(title: "Ошибка добавления контакта"))
      }
      moduleOutput?.dataModelHasBeenUpdated()
      updateListContacts()
    }
  }
  
  func cancelRequestForDialog(contactModel: ContactModel) {
    removeContactModels(contactModel) { [weak self] in
      guard let self else { return }
      interactor.showNotification(.positive(title: "Контакт был удален"))
    }
  }
  
  func sendMessage(_ message: String, contact: ContactModel) {
    guard contact.status == .online else {
      interactor.showNotification(.negative(title: "Контакт не в сети"))
      return
    }
    
    checkingContactPublicKey(contact: contact) { [weak self] updatedContactModel in
      guard let self else { return }
      sendMessageNetworkRequest(message, contact: updatedContactModel) { [weak self] result in
        guard let self else { return }
        switch result {
        case .success:
          moduleOutput?.dataModelHasBeenUpdated()
          updateListContacts()
        case let .failure(error):
          moduleOutput?.dataModelHasBeenUpdated()
          updateListContacts()
        }
      }
    }
  }
  
  func getContactModelsFrom(onionAddress: String, completion: ((ContactModel?) -> Void)?) {
    interactor.getContactModelsFrom(onionAddress: onionAddress, completion: completion)
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
  func initialSetup() {
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
      updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
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
      senderToxPublicKey: senderToxPublicKey
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
    _ message: String?,
    contact: ContactModel,
    completion: ((_ recipientTorAddress: String,
                  _ requestModel: MessengerNetworkRequestModel) -> Void)?
  ) {
    guard let senderPublicKey = interactor.publicKey(from: interactor.getDeviceIdentifier()) else {
      interactor.showNotification(.negative(title: "Не получилось создать Публичный ключ для шифрования"))
      return
    }
    
    interactor.saveContactModel(
      contact,
      completion: { [weak self] in
        guard let self else { return }
        var messageForSend = ""
        if let encryptionPublicKey = contact.encryptionPublicKey {
          let messageEncrypt = interactor.encrypt(message, publicKey: encryptionPublicKey)
          messageForSend = messageEncrypt ?? ""
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
              completion: completion
            )
          }
        }
      }
    )
  }
  
  func sendInitiateChatNetworkRequest(
    contact: ContactModel,
    completion: ((Result<Void, Error>) -> Void)?
  ) {
    prepareAndEncryptDataForNetworkRequest(
      nil,
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
    _ message: String,
    contact: ContactModel,
    completion: ((Result<Void, Error>) -> Void)?
  ) {
    guard let toxPublicKey = contact.toxPublicKey else {
      return
    }
    prepareAndEncryptDataForNetworkRequest(
      message,
      contact: contact
    ) { [weak self] recipientTorAddress, requestModel in
      guard let self else { return }
      
      interactor.sendMessage(
        toxPublicKey: toxPublicKey,
        messengerRequest: requestModel
      ) { [weak self] result in
        guard let self else { return }
        switch result {
        case .success:
          var updatedContact = contact
          if let messengeIndex = contact.messenges.firstIndex(where: {
            $0.id == updatedContact.messenges.last?.id
          }) {
            var updatedMessenge = updatedContact.messenges[messengeIndex]
            updatedMessenge.messageStatus = .sent
            updatedContact.messenges[messengeIndex] = updatedMessenge
          }
          
          interactor.saveContactModel(updatedContact) {
            completion?(.success(()))
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
        interactor.setStatus(contactModel, status) { [weak self] in
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
        
        updateRedDotToTabBar(contactModels: contactModels)
        
        let newContact = ContactModel(
          name: nil,
          toxAddress: messageModel.senderAddress,
          meshAddress: messageModel.senderLocalMeshAddress,
          messenges: [],
          status: .requestChat,
          encryptionPublicKey: messageModel.senderPublicKey,
          toxPublicKey: toxPublicKey,
          isNewMessagesAvailable: true
        )
        interactor.saveContactModel(newContact, completion: { [weak self] in
          guard let self else { return }
          updateListContacts()
          moduleOutput?.dataModelHasBeenUpdated()
        })
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
              isNewMessagesAvailable: true
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
  
  @objc func userDidScreenshot() {
    moduleOutput?.userDidScreenshot()
  }
}

// MARK: - Constants

private enum Constants {}
