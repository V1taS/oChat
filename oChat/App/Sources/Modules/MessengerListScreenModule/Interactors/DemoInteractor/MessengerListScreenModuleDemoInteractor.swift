//
//  MessengerListScreenModuleDemoInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.08.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKAbstractions
import SKStyle
import AVFoundation
import SKManagers

// swiftlint:disable all
final class MessengerListScreenModuleDemoInteractor {
  
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
  private let messengeDataManager: IMessengeDataManager
  private let appSettingsDataManager: IAppSettingsDataManager
  private let contactsDataManager: IContactsDataManager
  
  private var isFirstStartDemo = true
  
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
    self.messengeDataManager = services.messengerService.messengeDataManager
    self.appSettingsDataManager = services.messengerService.appSettingsDataManager
    self.contactsDataManager = services.messengerService.contactsDataManager
    
    Task { [weak self] in
      guard let self else { return }
      await firstStartDemoCheck()
    }
  }
}

// MARK: - MessengerListScreenModuleInteractorInput

extension MessengerListScreenModuleDemoInteractor: MessengerListScreenModuleInteractorInput {
  
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
  
  func getToxPublicKey(from address: String) -> String? {
    Constants.mockValue
  }
  
  func getToxAddress() async -> String? {
    Constants.mockValue
  }
  
  func getToxPublicKey() async -> String? {
    Constants.mockValue
  }
  
  func confirmFriendRequest(with publicToxKey: String) async -> String? {
    Constants.mockValue
  }
  
  func setSelfStatus(isOnline: Bool) async {}
  func setUserIsTyping(_ isTyping: Bool, to toxPublicKey: String) async -> Result<Void, Error> {
    .success(())
  }
  func startPeriodicFriendStatusCheck(completion: (() -> Void)?) async {}
  func stratTOXService() async {}
  
  // MARK: - ContactManager
  
  func getContactModels() async -> [ContactModel] {
    await firstStartDemoCheck()
    return await contactManager.getContactModels()
  }
  
  func saveContactModel(_ model: ContactModel) async {
    await firstStartDemoCheck()
    return await contactManager.saveContactModel(model)
  }
  
  func removeContactModels(_ contactModel: ContactModel) async -> Bool {
    await firstStartDemoCheck()
    return await contactManager.removeContactModel(contactModel)
  }
  
  func getContactModelsFrom(toxAddress: String) async -> ContactModel? {
    await firstStartDemoCheck()
    return await contactManager.getContactModelFrom(toxAddress: toxAddress)
  }
  
  func getContactModelsFrom(toxPublicKey: String) async -> ContactModel? {
    await firstStartDemoCheck()
    return await contactManager.getContactModelFrom(toxPublicKey: toxPublicKey)
  }
  
  func setStatus(_ model: ContactModel, _ status: ContactModel.Status) async {}
  func setAllContactsIsOffline() async {}
  
  func setAllContactsNoTyping() async {
    await firstStartDemoCheck()
    return await contactManager.setAllContactsNotTyping()
  }
  
  func clearAllMessengeTempID() async {
    await firstStartDemoCheck()
    return await messageManager.clearAllMessengeTempID()
  }
  
  // MARK: - SettingsManager
  
  func getAppSettingsModel() async -> AppSettingsModel {
    createAppSettingsModel()
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
    await notificationManager.requestNotification()
  }
  
  func isNotificationsEnabled() async -> Bool {
    await notificationManager.isNotificationsEnabled()
  }
  
  func saveMyPushNotificationToken(_ token: String) async {
    await notificationManager.saveMyPushNotificationToken(token)
  }
  
  func getPushNotificationToken() async -> String? {
    await notificationManager.getPushNotificationToken()
  }
  
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
  
  func clearTemporaryDirectory() {
    fileManager.clearTemporaryDirectory()
  }
  
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
    password: String
  ) async throws -> (
    model: MessengerNetworkRequestModel,
    recordingDTO: MessengeRecordingDTO?,
    files: [URL]
  ) {
    (MessengerNetworkRequestModel.defaultValue().mapToModel(), nil, [])
  }
  
  // MARK: - MessageManager
  
  func sendMessage(
    toxPublicKey: String,
    messengerRequest: MessengerNetworkRequestModel?
  ) async -> Int32? {
    .zero
  }
  
  func initialChat(
    senderAddress: String,
    messengerRequest: MessengerNetworkRequestModel?
  ) async -> Int32? {
    .zero
  }
  
  func sendFile(
    toxPublicKey: String,
    recipientPublicKey: String,
    recordModel: MessengeRecordingModel?,
    messengerRequest: MessengerNetworkRequestModel,
    files: [URL]
  ) async {}
  
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
  
  func getCurrentLanguage() -> AppLanguageType {
    systemService.getCurrentLanguage()
  }
  
  // MARK: - DeepLinkService
  
  func getDeepLinkAdress() async -> String? { nil }
  func deleteDeepLinkURL() {}
  
  // MARK: - NotificationService (Directly accessed)
  
  func showNotification(_ type: NotificationServiceType) {
    notificationService.showNotification(type)
  }
}

// MARK: - Private

private extension MessengerListScreenModuleDemoInteractor {
  func firstStartDemoCheck() async {
    guard isFirstStartDemo else {
      return
    }
    
    let contacts = createContacts()
    let contactsDictionary = Dictionary(uniqueKeysWithValues: contacts.map { ($0.id, $0) })
    await contactsDataManager.saveContactModels(contactsDictionary)
    await messengeDataManager.saveMessengeModels(createMessengesModels())
    await appSettingsDataManager.saveAppSettingsModel(createAppSettingsModel())
    isFirstStartDemo = false
  }
}

// MARK: - Constants

private enum Constants {
  static let mockValue = "b8d35bb4b73df0c50a06472ecb0d603241570a0507f49f570ae4ee39f5559c5587145ef0c540"
}
// swiftlint:enable all
