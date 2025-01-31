//
//  MessengerListScreenModuleFakeInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 06.08.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKAbstractions
import SKStyle
import AVFoundation
import SKManagers

final class MessengerListScreenModuleFakeInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MessengerListScreenModuleInteractorOutput?
  
  // MARK: - Private properties
  
  private let cryptoManager: ICryptoManager
  private let contactManager: IContactManager
  private let notificationManager: INotificationManager
  private let fileManager: ISKFileManager
  private let messageManager: IMessageManager
  private let settingsManager: ISettingsManager
  private let toxManager: IToxManager
  private let interfaceManager: IInterfaceManager
  
  private let systemService: ISystemService
  private let deepLinkService: IDeepLinkService
  private let notificationService: INotificationService
  private let p2pChatManager: IP2PChatManager
  private let messengeDataManager: IMessengeDataManager
  private let appSettingsDataManager: IAppSettingsDataManager
  private let contactsDataManager: IContactsDataManager
  private let sessionService: ISessionService
  
  // MARK: - Initialization
  
  init(
    services: IApplicationServices,
    cryptoManager: ICryptoManager,
    contactManager: IContactManager,
    notificationManager: INotificationManager,
    fileManager: ISKFileManager,
    messageManager: IMessageManager,
    settingsManager: ISettingsManager,
    toxManager: IToxManager,
    interfaceManager: IInterfaceManager
  ) {
    self.cryptoManager = cryptoManager
    self.contactManager = contactManager
    self.notificationManager = notificationManager
    self.fileManager = fileManager
    self.messageManager = messageManager
    self.settingsManager = settingsManager
    self.toxManager = toxManager
    self.interfaceManager = interfaceManager
    
    self.systemService = services.userInterfaceAndExperienceService.systemService
    self.deepLinkService = services.userInterfaceAndExperienceService.deepLinkService
    self.notificationService = services.userInterfaceAndExperienceService.notificationService
    self.p2pChatManager = services.messengerService.p2pChatManager
    self.messengeDataManager = services.messengerService.messengeDataManager
    self.appSettingsDataManager = services.messengerService.appSettingsDataManager
    self.contactsDataManager = services.messengerService.contactsDataManager
    self.sessionService = services.accessAndSecurityManagementService.sessionService
  }
}

// MARK: - MessengerListScreenModuleInteractorInput

extension MessengerListScreenModuleFakeInteractor: MessengerListScreenModuleInteractorInput {
  
  // MARK: - CryptoManager
  
  func decrypt(_ encryptedText: String?) async -> String? {
    await cryptoManager.decrypt(encryptedText)
  }
  
  func encrypt(_ text: String?, publicKey: String) -> String? {
    cryptoManager.encrypt(text, publicKey: publicKey)
  }
  
  func decrypt(_ encryptedData: Data?) async -> Data? {
    await cryptoManager.decrypt(encryptedData)
  }
  
  func encrypt(_ data: Data?, publicKey: String) -> Data? {
    cryptoManager.encrypt(data, publicKey: publicKey)
  }
  
  func publicKey(from privateKey: String) -> String? {
    cryptoManager.publicKey(from: privateKey)
  }
  
  // MARK: - ToxManager
  
  func getToxPublicKey(from address: String) -> String? { nil }
  func getToxAddress() async -> String? { nil }
  func getToxPublicKey() async -> String? { nil }
  func confirmFriendRequest(with publicToxKey: String) async -> String? { nil }
  func setSelfStatus(isOnline: Bool) async {}
  func setUserIsTyping(_ isTyping: Bool, to toxPublicKey: String) async -> Result<Void, Error> {
    .success(())
  }
  func startPeriodicFriendStatusCheck(completion: (() -> Void)?) async {}
  func startTOXService() async {}
  
  // MARK: - ContactManager
  
  func getContactModels() async -> [ContactModel] {
    return []
  }
  
  func saveContactModel(_ model: ContactModel) async {}
  func removeContactModels(_ contactModel: ContactModel) async -> Bool {
    true
  }
  
  func getContactModelsFrom(toxAddress: String) async -> ContactModel? {
    await contactManager.getContactModelFrom(toxAddress: toxAddress)
  }
  
  func getContactModelsFrom(toxPublicKey: String) async -> ContactModel? {
    await contactManager.getContactModelFrom(toxPublicKey: toxPublicKey)
  }
  
  func setStatus(_ model: ContactModel, _ status: ContactModel.Status) async {}
  func setAllContactsIsOffline() async {}
  func setAllContactsNoTyping() async {}
  func clearAllMessengeTempID() async {}
  
  // MARK: - SettingsManager
  
  func getAppSettingsModel() async -> AppSettingsModel {
    await settingsManager.getAppSettingsModel()
  }
  
  func passcodeNotSetInSystemIOSheck() async {
    await settingsManager.passcodeNotSetInSystemIOSCheck(
      errorMessage: OChatStrings.MessengerListScreenModuleLocalization
        .State.Notification.PasscodeNotSet.title
    )
  }
  
  // MARK: - NotificationManager
  
  func sendPushNotification(contact: ContactModel) async {}
  
  func requestNotification() async -> Bool {
    true
  }
  
  func isNotificationsEnabled() async -> Bool {
    true
  }
  
  func saveMyPushNotificationToken(_ token: String) async {}
  func getPushNotificationToken() async -> String? { nil }
  
  // MARK: - FileManager
  
  func getFileNameWithoutExtension(from url: URL) -> String {
    fileManager.getFileNameWithoutExtension(from: url)
  }
  
  func getFileName(from url: URL) -> String? {
    fileManager.getFileName(from: url)
  }
  
  func saveObjectToCachesWith(fileName: String, fileExtension: String, data: Data) -> URL? {
    fileManager.saveObjectToCachesWith(
      fileName: fileName,
      fileExtension: fileExtension,
      data: data
    )
  }
  
  func saveObjectWith(fileName: String, fileExtension: String, data: Data) -> URL? {
    fileManager.saveObjectWith(fileName: fileName, fileExtension: fileExtension, data: data)
  }
  
  func readObjectWith(fileURL: URL) -> Data? {
    fileManager.readObjectWith(fileURL: fileURL)
  }
  
  func clearTemporaryDirectory() {}
  
  func saveObjectWith(tempURL: URL) -> URL? {
    fileManager.saveObjectWith(tempURL: tempURL)
  }
  
  func getFirstFrame(from url: URL) -> Data? {
    fileManager.getFirstFrame(from: url)
  }
  
  func resizeThumbnailImageWithFrame(data: Data) -> Data? {
    fileManager.resizeThumbnailImageWithFrame(data: data)
  }
  
  func receiveAndUnzipFile(
    zipFileURL: URL,
    password: String,
    completion: @escaping (Result<(
      model: MessengerNetworkRequestModel,
      recordingDTO: MessengeRecordingDTO?,
      files: [URL]
    ), Error>) -> Void
  ) {
    fileManager.receiveAndUnzipFile(zipFileURL: zipFileURL, password: password, completion: completion)
  }
  
  // MARK: - MessageManager
  
  func sendMessage(
    toxPublicKey: String,
    messengerRequest: MessengerNetworkRequestModel?
  ) async -> Int32? {
    await messageManager.sendMessage(
      toxPublicKey: toxPublicKey,
      messengerRequest: messengerRequest
    )
  }
  
  func initialChat(
    senderAddress: String,
    messengerRequest: MessengerNetworkRequestModel?
  ) async -> Int32? {
    await messageManager.initialChat(
      senderAddress: senderAddress,
      messengerRequest: messengerRequest
    )
  }
  
  func sendFile(
    toxPublicKey: String,
    recipientPublicKey: String,
    recordModel: MessengeRecordingModel?,
    messengerRequest: MessengerNetworkRequestModel,
    files: [URL]
  ) async {
    await messageManager.sendFile(
      toxPublicKey: toxPublicKey,
      recipientPublicKey: recipientPublicKey,
      recordModel: recordModel,
      messengerRequest: messengerRequest,
      files: files
    )
  }
  
  func getListMessengeModels(_ contactModel: ContactModel) async -> [MessengeModel] {
    await messengeDataManager.getListMessengeModels(contactModel)
  }
  
  func addMessenge(_ contactID: String, _ messengeModel: MessengeModel) async {
    await messengeDataManager.addMessenge(contactID, messengeModel)
  }
  
  func updateMessenge(_ contactModel: ContactModel, _ messengeModel: MessengeModel) async {
    await messengeDataManager.updateMessenge(contactModel, messengeModel)
  }
  
  func removeMessenge(_ contactModel: ContactModel, _ id: String) async {
    await messengeDataManager.removeMessenge(contactModel, id)
  }
  
  func getMessengeModelsFor(_ contactID: String) async -> [MessengeModel] {
    await messengeDataManager.getMessengeModelsFor(contactID)
  }
  
  func getDictionaryMessengeModels() async -> MessengeModels {
    await messengeDataManager.getDictionaryMessengeModels()
  }
  
  func removeMessenges(_ contactModel: ContactModel) async {
    await messengeDataManager.removeMessenges(contactModel)
  }
  
  // MARK: - InterfaceManager
  
  func setRedDotToTabBar(value: String?) {
    interfaceManager.setRedDotToTabBar(value: value)
  }
  
  // MARK: - SystemService
  
  func getDeviceIdentifier() -> String {
    systemService.getDeviceIdentifier()
  }
  
  func getCurrentLanguage() -> SKAbstractions.AppLanguageType {
    systemService.getCurrentLanguage()
  }
  
  // MARK: - DeepLinkService
  
  func getDeepLinkAdress() async -> String? { nil }
  
  func deleteDeepLinkURL() {}
  
  // MARK: - NotificationService (Directly accessed)
  
  func showNotification(_ type: NotificationServiceType) {
    notificationService.showNotification(type)
  }
  
  // MARK: - Session
  
  func isSessionActive() -> Bool {
    sessionService.isSessionActive()
  }
  
  func sessionDidExpire() {
    sessionService.sessionDidExpire()
  }
}

// MARK: - Private

private extension MessengerListScreenModuleFakeInteractor {}

// MARK: - Constants

private enum Constants {}
