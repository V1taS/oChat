//
//  MessengerListScreenModuleMockInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 02.08.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKAbstractions
import SKStyle
import AVFoundation

/// Интерактор
final class MessengerListScreenModuleMockInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MessengerListScreenModuleInteractorOutput?
  
  // MARK: - Private properties
  
  private let notificationService: INotificationService
  private var p2pChatManager: IP2PChatManager
  private let modelHandlerService: IMessengerModelHandlerService
  private let deepLinkService: IDeepLinkService
  private let cryptoService: ICryptoService
  private let systemService: ISystemService
  private let modelSettingsManager: IMessengerModelSettingsManager
  private let permissionService: IPermissionService
  private let pushNotificationService: IPushNotificationService
  private let zipArchiveService: IZipArchiveService
  private var cacheFriendStatus: [String: Bool] = [:]
  private let dataManagementService: IDataManagerService
  
  private var messengerModel: MessengerModel = .init(
    appSettingsModel: .init(
      appPassword: nil,
      fakeAppPassword: nil,
      accessType: .demo,
      pushNotificationToken: "Demo",
      isNotificationsEnabled: true,
      myStatus: .online,
      toxStateAsString: nil,
      isPremiumEnabled: true,
      isTypingIndicatorEnabled: true,
      canSaveMedia: true,
      isChatHistoryStored: true,
      isVoiceChangerEnabled: true
    ),
    contacts: createMockContacts()
  )
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(services: IApplicationServices) {
    notificationService = services.userInterfaceAndExperienceService.notificationService
    p2pChatManager = services.messengerService.p2pChatManager
    modelHandlerService = services.messengerService.modelHandlerService
    deepLinkService = services.userInterfaceAndExperienceService.deepLinkService
    cryptoService = services.accessAndSecurityManagementService.cryptoService
    systemService = services.userInterfaceAndExperienceService.systemService
    modelSettingsManager = services.messengerService.modelSettingsManager
    permissionService = services.accessAndSecurityManagementService.permissionService
    pushNotificationService = services.pushNotificationService
    zipArchiveService = services.dataManagementService.zipArchiveService
    dataManagementService = services.dataManagementService.dataManagerService
  }
}

// MARK: - MessengerListScreenModuleInteractorInput

extension MessengerListScreenModuleMockInteractor: MessengerListScreenModuleInteractorInput {
  func decrypt(_ encryptedText: String?) async -> String? { encryptedText }
  func encrypt(_ text: String?, publicKey: String) -> String? { text }
  func decrypt(_ encryptedData: Data?) async -> Data? { encryptedData }
  func encrypt(_ data: Data?, publicKey: String) -> Data? { data }
  func publicKey(from privateKey: String) -> String? { "Demo" }
  func getToxPublicKey(from address: String) -> String? { "Demo" }
  func getDeviceIdentifier() -> String { "Demo" }
  func getDeepLinkAdress() async -> String? { nil }
  func deleteDeepLinkURL() {}
  func initialChat(
    senderAddress: String,
    messengerRequest: MessengerNetworkRequestModel?
  ) async -> Int32? { nil }
  func getToxPublicKey() async -> String? { nil }
  func getToxAddress() async -> String? { nil }
  func getContactModelsFrom(toxAddress: String) async -> SKAbstractions.ContactModel? { nil }
  func getContactModelsFrom(toxPublicKey: String) async -> SKAbstractions.ContactModel? { nil }
  func setAllContactsIsOffline() async {}
  func passcodeNotSetInSystemIOSheck() {}
  func stratTOXService() async {}
  func setRedDotToTabBar(value: String?) {}
  func setUserIsTyping(_ isTyping: Bool, to toxPublicKey: String) async -> Result<Void, any Error> { .success(())}
  func setSelfStatus(isOnline: Bool) async {}
  func setAllContactsNoTyping() async {}
  func getPushNotificationToken() async -> String? { nil }
  func saveMyPushNotificationToken(_ token: String) async {}
  func requestNotification() async -> Bool { true }
  func isNotificationsEnabled() async -> Bool { true }
  func sendPushNotification(contact: SKAbstractions.ContactModel) async {}
  func startPeriodicFriendStatusCheck(completion: (() -> Void)?) async {}
  func clearAllMessengeTempID() async {}
  func resizeThumbnailImageWithFrame(data: Data) -> Data? { nil }
  func readObjectWith(fileURL: URL) -> Data? { nil }
  func clearTemporaryDirectory() {}
  func saveObjectWith(tempURL: URL) -> URL? { nil }
  func saveObjectWith(fileName: String, fileExtension: String, data: Data) -> URL? { nil }
  func saveObjectToCachesWith(fileName: String, fileExtension: String, data: Data) -> URL? { nil }
  func getFileName(from url: URL) -> String? { nil }
  func getFileNameWithoutExtension(from url: URL) -> String { "" }
  func getFirstFrame(from url: URL) -> Data? { nil }
  func confirmFriendRequest(with publicToxKey: String) async -> String? { nil }
  func setStatus(_ model: SKAbstractions.ContactModel, _ status: SKAbstractions.ContactModel.Status) async {}
  func receiveAndUnzipFile(zipFileURL: URL, password: String) async throws -> (
    model: SKAbstractions.MessengerNetworkRequestModel,
    recordingDTO: SKAbstractions.MessengeRecordingDTO?,
    files: [URL]
  ) {
    return (
      model: .init(
        messageText: nil,
        messageID: nil,
        replyMessageText: nil,
        senderAddress: "",
        senderLocalMeshAddress: nil,
        senderPublicKey: nil,
        senderToxPublicKey: nil,
        senderPushNotificationToken: nil,
        canSaveMedia: true,
        isChatHistoryStored: true
      ),
      recordingDTO: nil,
      files: []
    )
  }
  
  func showNotification(_ type: NotificationServiceType) {
    DispatchQueue.main.async { [weak self] in
      self?.notificationService.showNotification(type)
    }
  }
  
  func getContactModels() async -> [ContactModel] {
    messengerModel.contacts
  }
  
  func saveContactModel(_ value: ContactModel) async {
    var model = messengerModel
    var updatedContactModel: [ContactModel] = model.contacts
    
    if let contactIndex = updatedContactModel.firstIndex(where: { $0.id == value.id }) {
      updatedContactModel[contactIndex] = value
    } else {
      updatedContactModel.append(value)
    }
    
    model.contacts = updatedContactModel
    messengerModel = model
  }
  
  func removeContactModels(_ contactModel: ContactModel) async -> Bool {
    var model = messengerModel
    var updatedContactModel: [ContactModel] = model.contacts
    
    if let contactIndex = updatedContactModel.firstIndex(of: contactModel) {
      updatedContactModel.remove(at: contactIndex)
    }
    model.contacts = updatedContactModel
    messengerModel = model
    return true
  }
  
  func getMessengerModel() async -> MessengerModel {
    messengerModel
  }
  
  func sendMessage(toxPublicKey: String, messengerRequest: MessengerNetworkRequestModel?) async -> Int32? {
    nil
  }
  
  func sendFile(
    toxPublicKey: String,
    recipientPublicKey: String,
    recordModel: SKAbstractions.MessengeRecordingModel?,
    messengerRequest: SKAbstractions.MessengerNetworkRequestModel,
    files: [URL]
  ) async {}
  
  func getAppSettingsModel() async -> AppSettingsModel {
    messengerModel.appSettingsModel
  }
}

func createMockContacts() -> [ContactModel] {
  let contactSymbols = [
    "A1",
    "B2",
    "C3",
    "D4",
    "E5",
    "F6",
    "G7",
    "H8",
    "I9",
    "J0",
    "K1",
    "L2",
    "M3",
    "N4",
    "O5",
    "P6",
    "Q7"
  ]
  var contacts: [ContactModel] = []
  
  for symbol in contactSymbols {
    let messages = createMockMessages(count: Int.random(in: 5...40))
    let contact = ContactModel(
      name: nil,
      toxAddress: "\(symbol)",
      meshAddress: "\(symbol)",
      messenges: messages,
      status: Bool.random() ? .online : .offline,
      encryptionPublicKey: "encryptionPublicKey_\(symbol)",
      toxPublicKey: "toxPublicKey_\(symbol)",
      pushNotificationToken: "pushNotificationToken_\(symbol)",
      isNewMessagesAvailable: true,
      isTyping: false,
      canSaveMedia: true,
      isChatHistoryStored: true
    )
    contacts.append(contact)
  }
  
  return contacts
}

func createMockMessages(count: Int) -> [MessengeModel] {
  let conversationPairs = [
    ("Привет, как дела?", "Привет! Все хорошо, а у тебя?"),
    ("Что нового?", "Ничего особенного, работаю."),
    ("Пойдешь в кино?", "Да, с удовольствием! Когда?"),
    ("Увидел новость?", "Да, это шок!"),
    ("Как прошли выходные?", "Отлично, ездил на природу."),
    ("Есть планы на вечер?", "Думаю почитать книгу."),
    ("Как тебе новая технология?", "Очень интересно, много возможностей."),
    ("Поможешь с проектом?", "Конечно, чем могу помочь?"),
    ("Какой твой любимый фильм?", "Мне нравится 'Интерстеллар'."),
    ("Как твоя семья?", "Все хорошо, спасибо."),
    ("Какие планы на отпуск?", "Поеду на море."),
    ("Ты слышал про новую игру?", "Да, выглядит здорово!"),
    ("Как продвигается работа?", "Все идет по плану."),
    ("Что думаешь о погоде?", "Жарковато сегодня."),
    ("Какие у тебя хобби?", "Люблю фотографировать."),
    ("У тебя есть домашние животные?", "Да, у меня есть кот."),
    ("Как тебе новая книга?", "Очень захватывающая, не могу оторваться.")
  ]
  
  var messages: [MessengeModel] = []
  
  for i in 0..<count {
    let pairIndex = i % conversationPairs.count
    let isOutgoing = i % 2 == 0
    let messageType: MessengeModel.MessageType = isOutgoing ? .own : .received
    let messageText = isOutgoing ? conversationPairs[pairIndex].0 : conversationPairs[pairIndex].1
    
    let message = MessengeModel(
      messageType: messageType,
      messageStatus: .sent,
      message: messageText,
      replyMessageText: nil,
      images: [],
      videos: [],
      recording: nil
    )
    messages.append(message)
  }
  
  return messages
}
