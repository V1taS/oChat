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
}

// MARK: - MessengerListScreenModuleModuleInput

extension MessengerListScreenModulePresenter: MessengerListScreenModuleModuleInput {
  func removeMessage(_ message: String?, contact: ContactModel, completion: (() -> Void)?) {
    var updatedContact = factory.removeMessageToContact(message: message, contactModel: contact)
    interactor.saveContactModel(updatedContact, completion: completion)
  }
  
  func getContactModelsFrom(onionAddress: String, completion: ((ContactModel?) -> Void)?) {
    interactor.getContactModelsFrom(onionAddress: onionAddress, completion: completion)
  }
  
  func sendMessage(_ message: String, contact: ContactModel) {
    sendMessageNetworkRequest(message, contact: contact) { [weak self] result in
      guard let self else { return }
      switch result {
      case .success:
        moduleOutput?.dataModelHasBeenUpdated()
        setContactStatus(.online, contact: contact)
        interactor.showNotification(.positive(title: "Сообщение отправлено"))
        updateListContacts()
      case let .failure(error):
        removeMessage(message, contact: contact) { [weak self] in
          guard let self else { return }
          moduleOutput?.dataModelHasBeenUpdated()
          setContactStatus(.offline, contact: contact)
          interactor.showNotification(.negative(title: "Сообщение не отправлено. \(error.localizedDescription)"))
          updateListContacts()
        }
      }
    }
  }
  
  func sendInitiateChat(onionAddress: String) {
    guard let myPublicKey = interactor.publicKey(from: interactor.getDeviceIdentifier()) else {
      interactor.showNotification(.negative(title: "Не получилось создать Публичный ключ для шифрования"))
      return
    }
    
    interactor.getContactModelsFrom(onionAddress: onionAddress) { [weak self] contactModel in
      guard let self else { return }
      
      let contact = contactModel ?? ContactModel(
        name: nil,
        onionAddress: onionAddress,
        meshAddress: nil,
        messenges: [],
        status: .requested,
        encryptionPublicKey: nil,
        isPasswordDialogProtected: false
      )
      
      sendInitiateChatNetworkRequest(contact: contact) { [weak self] result in
        guard let self else { return }
        switch result {
        case .success:
          moduleOutput?.dataModelHasBeenUpdated()
          setContactStatus(.online, contact: contact)
          interactor.showNotification(.positive(title: "Сообщение отправлено"))
          updateListContacts()
        case let .failure(error):
          moduleOutput?.dataModelHasBeenUpdated()
          setContactStatus(.offline, contact: contact)
          interactor.showNotification(.negative(title: "Сообщение не отправлено. \(error.localizedDescription)"))
          updateListContacts()
        }
      }
    }
  }
  
  func removeContactModels(_ contactModel: ContactModel, completion: (() -> Void)?) {
    interactor.removeContactModels(contactModel) { [weak self]in
      guard let self else {
        return
      }
      updateListContacts(completion: completion)
    }
  }
  
  func updateListContacts(completion: (() -> Void)? = nil) {
    interactor.getContactModels { [weak self] contactModels in
      guard let self else {
        return
      }
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
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleOnlineStatus(_:)),
      name: Notification.Name(NotificationConstants.didUpdateOnlineStatusName),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleUpdateListContacts(_:)),
      name: Notification.Name(NotificationConstants.updateListContacts),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleMessage(_:)),
      name: Notification.Name(NotificationConstants.didReceiveMessageName),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleInitial(_:)),
      name: Notification.Name(NotificationConstants.didInitiateChatName),
      object: nil
    )
  }
  
  func setupSKBarButtonView() {
    barButtonView = SKBarButtonView(
      .init(
        leftImage: nil,
        centerText: nil,
        rightImage: nil,
        isEnabled: false,
        action: {}
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
    recipientTorAddress: String?,
    recipientLocalMeshAddress: String?,
    senderPublicKey: String,
    completion: ((_ recipientTorAddress: String,
                  _ requestModel: MessengerNetworkRequestModel) -> Void)?
  ) {
    guard let recipientTorAddress else {
      interactor.showNotification(.negative(title: "Нет адреса получателя!"))
      return
    }
    
    interactor.getOnionAddress { [weak self] result in
      guard let self else { return }
      
      let requestModel = MessengerNetworkRequestModel(
        messageText: message,
        recipientTorAddress: recipientTorAddress,
        recipientLocalMeshAddress: recipientLocalMeshAddress ?? "",
        senderPublicKey: senderPublicKey,
        senderContactStatus: .online
      )
      completion?(recipientTorAddress, requestModel)
    }
  }
  
  func setContactStatus(_ status: ContactModel.Status, contact: ContactModel) {
    if contact.status != .requested {
      interactor.setStatus(contact, status, completion: {})
    }
  }
  
  func prepareAndEncryptDataForNetworkRequest(
    _ message: String?,
    contact: ContactModel,
    completion: ((_ recipientTorAddress: String,
                  _ requestModel: MessengerNetworkRequestModel) -> Void)?
  ) {
    guard let myPublicKey = interactor.publicKey(from: interactor.getDeviceIdentifier()) else {
      interactor.showNotification(.negative(title: "Не получилось создать Публичный ключ для шифрования"))
      removeMessage(message, contact: contact, completion: {})
      return
    }
    
    let message = interactor.encrypt(message, publicKey: myPublicKey)
    var updatedContact = factory.addMessageToContact(
      message: message,
      contactModel: contact,
      messageType: .own
    )
    interactor.saveContactModel(updatedContact, completion: {})
    
    guard let onionAddress = updatedContact.onionAddress else {
      interactor.showNotification(.negative(title: "Сообщение не отправлено. Отсутствует адрес получателя"))
      removeMessage(message, contact: contact, completion: {})
      return
    }
    
    createRequestModel(
      message: message,
      recipientTorAddress: onionAddress,
      recipientLocalMeshAddress: updatedContact.meshAddress,
      senderPublicKey: myPublicKey,
      completion: completion
    )
  }
  
  func sendInitiateChatNetworkRequest(
    contact: ContactModel,
    completion: ((Result<Void, Error>) -> Void)?
  ) {
    prepareAndEncryptDataForNetworkRequest(nil, contact: contact) { [weak self] recipientTorAddress, requestModel in
      guard let self else { return }
      interactor.initiateChat(
        onionAddress: recipientTorAddress,
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
    prepareAndEncryptDataForNetworkRequest(message, contact: contact) { [weak self] recipientTorAddress, requestModel in
      guard let self else { return }
      interactor.sendMessage(
        onionAddress: recipientTorAddress,
        messengerRequest: requestModel
      ) { [weak self] result in
        guard let self else { return }
        switch result {
        case .success:
          var updatedContact = contact
          if let messengeIndex = contact.messenges.firstIndex(where: { $0.id == updatedContact.messenges.last?.id }) {
            var updatedMessenge = updatedContact.messenges[messengeIndex]
            updatedMessenge.messageStatus = .delivered
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
  @objc func appDidBecomeActive() {
    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
      self?.interactor.getDeepLinkAdress { [weak self] adress in
        guard let self, let adress else {
          return
        }
        
        moduleOutput?.openNewMessengeScreen(contactAdress: adress)
        interactor.deleteDeepLinkURL()
      }
    }
  }
  
  @objc
  func handleOnlineStatus(_ notification: Notification) {
    if let status = notification.userInfo?["onlineStatus"] as? ContactModel.Status {
      barButtonView?.iconLeftView.image = status.imageStatus
      barButtonView?.labelView.text = status.title
    }
  }
  
  @objc
  func handleUpdateListContacts(_ notification: Notification) {
    updateListContacts()
  }
  
  @objc
  func handleInitial(_ notification: Notification) {
    if let messageModel = notification.userInfo?["initiateChat"] as? MessengerNetworkRequestModel {
      interactor.getContactModels { [weak self] contactModels in
        guard let self,
              contactModels.contains(where: { $0.onionAddress != messageModel.recipientTorAddress }) else {
          return
        }
        let newContact = ContactModel(
          name: nil,
          onionAddress: messageModel.recipientTorAddress,
          meshAddress: messageModel.recipientTorAddress,
          messenges: [],
          status: .requested,
          encryptionPublicKey: messageModel.senderPublicKey,
          isPasswordDialogProtected: false
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
    if let messageModel = notification.userInfo?["data"] as? MessengerNetworkRequestModel {
      interactor.getContactModels { [weak self] contactModels in
        guard let self else {
          return
        }
        
        if let contact = factory.searchContact(
          contactModels: contactModels,
          torAddress: messageModel.recipientTorAddress
        ) {
          var updatedContact = contact
          updatedContact.encryptionPublicKey = messageModel.senderPublicKey
          updatedContact = factory.addMessageToContact(
            message: messageModel.messageText,
            contactModel: updatedContact,
            messageType: .received
          )
          updatedContact.meshAddress = messageModel.recipientLocalMeshAddress
          updatedContact.status = .online
          interactor.saveContactModel(updatedContact, completion: { [weak self] in
            guard let self else { return }
            updateListContacts()
            moduleOutput?.dataModelHasBeenUpdated()
          })
        } else {
          let contact = ContactModel(
            name: nil,
            onionAddress: messageModel.recipientTorAddress,
            meshAddress: messageModel.recipientLocalMeshAddress,
            messenges: [],
            status: .requested,
            encryptionPublicKey: messageModel.senderPublicKey,
            isPasswordDialogProtected: false
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

// MARK: - Constants

private enum Constants {}
